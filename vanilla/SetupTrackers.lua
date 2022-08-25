if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers")

local Timers = XiTimers.timers
local SpellNames = TotemTimers.SpellNames
local SpellIDs = TotemTimers.SpellIDs
local SpellTextures = TotemTimers.SpellTextures
local AvailableSpells = TotemTimers.AvailableSpells

local ankh = nil
local shield = nil

local playerName = UnitName("player")

local buttons = {"LeftButton", "RightButton", "MiddleButton", "Button4"}

local function splitString(ustring)
    local c = 0
    local s = ""
    for uchar in string.gmatch(ustring, "([%z\1-\127\194-\244][\128-\191]*)") do
        c = c + 1
        s = s..uchar
        if c == 4 then break end
    end
    return s
end



function TotemTimers.CreateTrackers()
	-- ankh tracker
	ankh = XiTimers:new(1)
	ankh.button:SetScript("OnEvent", TotemTimers.AnkhEvent)
	ankh.button.icons[1]:SetTexture(SpellTextures[SpellIDs.Ankh])
	ankh.events[1] = "SPELL_UPDATE_COOLDOWN"
	ankh.events[2] = "BAG_UPDATE"
	ankh.button.anchorframe = TotemTimers_TrackerFrame
	ankh.showCooldown = true
	ankh.dontAlpha = true
	ankh.button.icons[1]:SetAlpha(1)
	ankh.timeStyle = "blizz"
	ankh.Activate = function(self) 
        XiTimers.Activate(self) 
        TotemTimers.AnkhEvent(ankh.button, "SPELL_UPDATE_COOLDOWN")
        TotemTimers.AnkhEvent(ankh.button, "BAG_UPDATE")
        TotemTimers.ProcessSetting("TimerSize")
    end
	ankh.button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    ankh.Deactivate = function(self)
        XiTimers.Deactivate(self)
        TotemTimers.ProcessSetting("TimerSize")
    end
    ankh.button.cooldown.noCooldownCount = true
    ankh.button.cooldown.noOCC = true
		
	shield = XiTimers:new(1)
	shield.button.icons[1]:SetTexture(SpellTextures[SpellIDs.LightningShield])
	shield.button.anchorframe = TotemTimers_TrackerFrame
	shield.button:SetScript("OnEvent", TotemTimers.ShieldEvent)
	shield.events[1] = "UNIT_SPELLCAST_SUCCEEDED"
	shield.events[2] = "UNIT_AURA"
	shield.timeStyle = "blizz"
	shield.Activate = function(self)
        XiTimers.Activate(self)
        TotemTimers.ShieldEvent(self.button, "UNIT_AURA")
        if not TotemTimers.ActiveProfile.ShieldTracker then
            self.button:Hide()
        end
      end
	shield.button:SetAttribute("*type*", "spell")
    shield.button:SetAttribute("*unit*", "player")
	shield.button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    shield.button:SetAttribute("*spell1", SpellNames[SpellIDs.LightningShield])
    shield.button:SetScript("OnDragStop", function(self)
        XiTimers.StopMoving(self)
    end)
    ankh.button:SetScript("OnDragStop", function(self)
        XiTimers.StopMoving(self)
    end)

    local earthshield = XiTimers:new(1) -- unused for classic, but necessary
end

table.insert(TotemTimers.Modules, TotemTimers.CreateTrackers)

local AnkhName = SpellNames[SpellIDs.Ankh]
local AnkhID = SpellIDs.Ankh
local AnkhItem = 17030

function TotemTimers.AnkhEvent(self, event)
    if event == "SPELL_UPDATE_COOLDOWN" then
        if not AvailableSpells[SpellIDs.Ankh] then return end
        local start, duration, enable = GetSpellCooldown(AnkhID)
        if duration == 0 then
            self.timer:Stop(1)
        elseif self.timer.timers[1]<=0 and duration>2 then
            self.timer:Start(1,start+duration-floor(GetTime()),duration)
        end
    else
        self.count:SetText(GetItemCount(AnkhItem))
    end
end

--local shieldtable = {SpellNames[SpellIDs.LightningShield], SpellNames[SpellIDs.WaterShield], SpellNames[SpellIDs.EarthShield]}
local LightningShield = SpellNames[SpellIDs.LightningShield]
local ShieldChargesOnly = false

function TotemTimers.ShieldEvent(self, event, unit)
	if event=="UNIT_SPELLCAST_SUCCEEDED" and unit=="player" then
		local start, duration, enable = GetSpellCooldown(SpellIDs.LightningShield)
		if start and duration and (not self.timer.timerOnButton or self.timer.timers[1]<=0) then
            CooldownFrame_Set(self.cooldown, start, duration, enable)
        end
	elseif unit=="player" then
		self.count:SetText("")
		local name, texture, count, duration, endtime
        local hasBuff = false
        for i=1,40 do
            name,texture,count,_,duration,endtime = UnitBuff("player", i)
            if name == LightningShield then
                hasBuff = true
                local timeleft = endtime - GetTime()
                if name ~= self.shield or timeleft>self.timer.timers[1] then
                    self.icons[1]:SetTexture(texture)
                    self.timer.expirationMsgs[1] = "Shield"
                    self.timer.earlyExpirationMsgs[1] = "Shield"
                    self.timer.warningIcons[1] = texture
                    self.timer.warningSpells[1] = name
                    self.shield = name
                    if not ShieldChargesOnly then
                        self.timer:Start(1, timeleft, duration)
                    else
                        self.timer:Start(1, count, 3)
                    end
                end
                if not ShieldChargesOnly then
                    if count and count > 0 then
                        self.count:SetText(count)
                    else
                        self.count:SetText("")
                    end
                end
                break
            end
        end
		if not hasBuff and self.timer.timers[1]>0 then
			self.timer:Stop(1)
		end
	end  
end

local function EmptyUpdate() end

function TotemTimers.SetShieldUpdate()
    ShieldChargesOnly = TotemTimers.ActiveProfile.ShieldChargesOnly
    if ShieldChargesOnly then
        Timers[6].Update = EmptyUpdate
        Timers[6].prohibitCooldown = true
        Timers[6].timeStyle = "sec"
        Timers[6].button.count:SetText("")
    else
        Timers[6].Update = nil
        Timers[6].prohibitCooldown = false
        Timers[6].timeStyle = TotemTimers.ActiveProfile.TimeStyle --"blizz"
    end
    TotemTimers.ShieldEvent(Timers[6].button, "UNIT_AURA", "player")
end



local ButtonPositions = {
	["box"] = {{"CENTER",0,"CENTER"},{"LEFT",1,"RIGHT"},{"TOP",2,"BOTTOM"},{"LEFT",1,"RIGHT"}},
	["horizontal"] = {{"CENTER",0,"CENTER"},{"LEFT",1,"RIGHT"},{"LEFT",1,"RIGHT"},{"LEFT",1,"RIGHT"}},
	["vertical"] = {{"CENTER",0,"CENTER"},{"TOP",1,"BOTTOM"},{"TOP",1,"BOTTOM"},{"TOP",1,"BOTTOM"}}	
}

local TrackerOptions = {
    [5] = "AnkhTracker",
    [6] = "ShieldTracker",
}

function TotemTimers.OrderTrackers()
	local arrange = TotemTimers.ActiveProfile.TrackerArrange
    for e=5,8 do
		Timers[e]:ClearAnchors()
		Timers[e].button:ClearAllPoints()
	end
    if arrange == "free" then
        for i=5,8 do
            Timers[i].savePos = true
            local pos = TotemTimers.ActiveProfile.TimerPositions[i]            
            if not pos or not pos[1] then pos = {"CENTER", "UIParent", "CENTER", 0,0} end
            Timers[i].button:ClearAllPoints()
            Timers[i].button:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
        end
    else
    	local counter = 0
    	local buttons = {}
    	for i=5,8 do
            Timers[i].savePos = false
    		--if Timers[i].active then
            if Timers[i].button:IsVisible() then
    			counter = counter + 1
    			if counter == 1 then
    				Timers[i]:SetPoint(ButtonPositions[arrange][1][1], TotemTimers_TrackerFrame, ButtonPositions[arrange][1][3])
    			else
    				Timers[i]:Anchor(buttons[counter-ButtonPositions[arrange][counter][2]], ButtonPositions[arrange][counter][1])	
    			end
    			buttons[counter] = Timers[i]
    		end
    	end
    end
end

