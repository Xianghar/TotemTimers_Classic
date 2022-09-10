if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local _, TotemTimers = ...

local SpellIDs = TotemTimers.SpellIDs
local SpellTextures = TotemTimers.SpellTextures
local SpellNames = TotemTimers.SpellNames
local AvailableSpells = TotemTimers.AvailableSpells
local FlameShockID = SpellIDs.FlameShock
local FlameShockName = SpellNames[SpellIDs.FlameShock]

local cds = {}
TotemTimers.EnhanceCDs = cds

local role = 2

local function NoUpdate()
end

local ShieldName = SpellNames[SpellIDs.LightningShield]

local CDSpells = TotemTimers.CombatCooldownSpells

local FlameShockDuration = null


local function ChangeCDOrder(self,spell)
--[[    if InCombatLockdown() then return end
    if not spell then return end
    local _,spell1 = GetSpellBookItemInfo(spell, "BOOKTYPE_SPELL")
    local spell2 = self:GetAttribute("orderspell")    
    if not spell2 or not spell1 then return end
    local spellnum1, spellnum2 = nil,nil
    for local i=1,num_CD_Spells[role] do
        if CD_Spells[role][i] == spell1 then spellnum1 = i end
        if CD_Spells[role][i] == spell2 then spellnum2 = i end        
    end
    if not spellnum1 or not spellnum2 then return end
    local order1, order2 = nil
    for i=1,#TotemTimers.ActiveProfile.EnhanceCDs_Order[role] do
        if TotemTimers.ActiveProfile.EnhanceCDs_Order[role][i] == spellnum1 then order1 = i end
        if TotemTimers.ActiveProfile.EnhanceCDs_Order[role][i] == spellnum2 then order2 = i end
    end
    if not order1 or not order2 then return end
    TotemTimers.ActiveProfile.EnhanceCDs_Order[role][order1], TotemTimers.ActiveProfile.EnhanceCDs_Order[role][order2] =
        TotemTimers.ActiveProfile.EnhanceCDs_Order[role][order2], TotemTimers.ActiveProfile.EnhanceCDs_Order[role][order1]
    TotemTimers.LayoutEnhanceCDs()
    ]]
end
   
function TotemTimers.CreateEnhanceCDs()
    for i = 1,12 do
        cds[i] = XiTimers:new(1)
        cds[i].events = {"SPELL_UPDATE_COOLDOWN"}
        cds[i].dontFlash = true
        cds[i].timeStyle = "sec"
        cds[i].button.anchorframe = TotemTimers_EnhanceCDsFrame
        cds[i].button:SetAttribute("*type*", "spell")
        cds[i].reverseAlpha = true
        cds[i].button.icons[1]:SetAlpha(1)
        cds[i].button:SetScript("OnEvent", TotemTimers.EnhanceCDEvents)
        cds[i].button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    end

    FlameShockDuration = XiTimers:new(1)
    TotemTimers.FlameShockDuration = FlameShockDuration
    FlameShockDuration.button:Disable()
    FlameShockDuration.button.icons[1]:SetVertexColor(1,1,1)
    FlameShockDuration.button.bar:SetStatusBarColor(1,0.2,0.2,0.8)
    FlameShockDuration.button.bar:SetStatusBarColor(1,0.2,0.2,0.8)

    FlameShockDuration.button.icons[1]:SetTexture(SpellTextures[SpellIDs.FlameShock])
    FlameShockDuration.button.anchorframe = TotemTimers_EnhanceCDsFrame
    FlameShockDuration.dontAlpha = true
    FlameShockDuration.dontFlash = true
    FlameShockDuration.timeStyle = "sec"
    FlameShockDuration.button:SetAttribute("*type1", "spell")
    FlameShockDuration.button:SetAttribute("*spell1", SpellNames[SpellIDs.FlameShock])
    FlameShockDuration.button.icons[1]:SetAlpha(1)
	FlameShockDuration.rangeCheck = SpellNames[SpellIDs.FlameShock]
	FlameShockDuration.manaCheck = SpellNames[SpellIDs.FlameShock]
    FlameShockDuration.button:SetScript("OnEvent", TotemTimers.FlameShockEvent)
    FlameShockDuration.events[1] = "COMBAT_LOG_EVENT_UNFILTERED"
    FlameShockDuration.events[2] = "UNIT_AURA"
    FlameShockDuration.events[3] = "PLAYER_REGEN_ENABLED"
    FlameShockDuration.events[4] = "PLAYER_REGEN_DISABLED"
    FlameShockDuration.events[5] = "PLAYER_TARGET_CHANGED"
	FlameShockDuration.forceBar = true
    FlameShockDuration:SetTimerBarPos("RIGHT")
    FlameShockDuration:SetTimeWidth(100)
    FlameShockDuration:SetBarColor(1,0.5,0)
	

    for i=1,#cds do
        cds[i].button:SetAttribute("_ondragstart",[[if IsShiftKeyDown() then
                                                    return "spell", self:GetAttribute("*spell1")
                                              else control:CallMethod("StartMove") end]])
        cds[i].button:SetAttribute("_onreceivedrag",[[ if kind == "spell" then
                                                   control:CallMethod("ChangeCDOrder", value, ...)
                                                    return "clear"
                                              end]])
        cds[i].button.ChangeCDOrder = ChangeCDOrder
    end
end

table.insert(TotemTimers.Modules, TotemTimers.CreateEnhanceCDs)

function TotemTimers.ConfigEnhanceCDs() 
    role = TotemTimers.Specialization --GetSpecialization()
    if not role then role = 0 end
    
    for i=1,#cds do
        cds[i]:Deactivate()
    end
    FlameShockDuration:Deactivate()

    if role == 0 or not TotemTimers.ActiveProfile.EnhanceCDs then return end

    
    for i=1,#CDSpells[role] do
        local spell = CDSpells[role][i]
        local cd = cds[i]
        cd.button.cdspell = spell
        cd.button.icons[1]:SetTexture(SpellTextures[spell])
        cd.button:SetAttribute("*spell1", spell)
        if spell == SpellIDs.FlameShock then
            cd.button:SetAttribute("*spell2", SpellIDs.EarthShock)
            cd.button:SetAttribute("*spell3", SpellIDs.FrostShock)
        elseif spell == SpellIDs.EarthShock then
            cd.button:SetAttribute("*spell2", SpellIDs.FlameShock)
            cd.button:SetAttribute("*spell2", SpellIDs.FrostShock)
        else
		    cd.button:SetAttribute("*spell2", nil)
		end
		cd.button:SetAttribute("*spell3", nil)
        cd.rangeCheck = SpellNames[CDSpells[role][i]]
        cd.manaCheck = SpellNames[CDSpells[role][i]]
        cd.Update = nil
        cd.prohibitCooldown = false
        cd.button:SetAttribute("orderspell", CDSpells[role][i])

        cd.reverseAlpha = true
        cd.Stop = nil

        cd.events = {"SPELL_UPDATE_COOLDOWN"}
        cd.playerEvents = {}

        --cd.button.bar:SetStatusBarColor(0.6,0.6,1.0,0.5)

        --[[if spell == SpellIDs.FlameShock or spell == SpellIDs.EarthShock then
            cd.button:SetScript("OnEvent", TotemTimers.ShockEvent)
            cd.playerEvents[1] = "UNIT_AURA"
        else]]
        if spell == SpellIDs.StormStrike then
            cd.button:SetScript("OnEvent", TotemTimers.StormStrikeEvent)
            cd.events[2] = "UNIT_AURA"
            cd.events[3] = "PLAYER_TARGET_CHANGED"
        elseif spell == SpellIDs.Searing or spell == SpellIDs.Magma then
            cd.button:SetScript("OnEvent", TotemTimers.FireTotemEvent)
            cd.events[2] = "PLAYER_TOTEM_UPDATE"
        else
            cd.button:SetScript("OnEvent", TotemTimers.EnhanceCDEvents)
        end
    end

    if AvailableSpells[SpellIDs.FlameShock] and TotemTimers.ActiveProfile.EnhanceCDsFlameShockDuration_Specialization[role] then
        FlameShockDuration:Activate()
    end
    
    for i=1,#CDSpells[role] do
        if TotemTimers.ActiveProfile.EnhanceCDs_Spells[role][i] and AvailableSpells[CDSpells[role][TotemTimers.ActiveProfile.EnhanceCDs_Order[role][i]]] then
            cds[i]:Activate()
        end
    end
end

local activeCDs = {}

local function ConvertCoords(frame1, frame2)
    return frame1:GetEffectiveScale()/frame2:GetEffectiveScale()
end


function TotemTimers.LayoutEnhanceCDs()
    wipe(activeCDs)
    if role == 0 then return end

    for i=1,#CDSpells[role] do
        if cds[TotemTimers.ActiveProfile.EnhanceCDs_Order[role][i]].active then
            table.insert(activeCDs,cds[TotemTimers.ActiveProfile.EnhanceCDs_Order[role][i]])
        end
    end
    for i=1,12 do
        cds[i]:ClearAnchors()
        cds[i].button:ClearAllPoints()
    end
    FlameShockDuration.button:ClearAllPoints()

    local numActiveCDs = #activeCDs

    if numActiveCDs == 0 then return end

    local topRow, bottomRow = numActiveCDs, 0

    if numActiveCDs > 5 then
        topRow = floor(numActiveCDs / 2)
        bottomRow = ceil(numActiveCDs / 2)
    end

    local split = ceil(topRow / 2)
    if topRow % 2 == 0 then
        activeCDs[split]:SetPoint("RIGHT", TotemTimers_EnhanceCDsFrame, "CENTER", -3, 0)
    else
        activeCDs[split]:SetPoint("CENTER", TotemTimers_EnhanceCDsFrame)
    end

    for i=split-1, 1, -1 do
        activeCDs[i]:Anchor(activeCDs[i+1], "RIGHT")
    end
    for i = split + 1, topRow do
        activeCDs[i]:Anchor(activeCDs[i-1], "LEFT")
    end

    local bottomSplit
    if bottomRow > 0 then
        bottomSplit = topRow + ceil(bottomRow / 2)
        if bottomRow == topRow then
            activeCDs[bottomSplit]:Anchor(activeCDs[split], "TOP")
        else
            activeCDs[bottomSplit]:Anchor(activeCDs[split], "TOPRIGHT", "BOTTOM", true)
        end
        for i=bottomSplit-1, topRow+1, -1 do
            activeCDs[i]:Anchor(activeCDs[i+1], "RIGHT")
        end
        for i = bottomSplit + 1, numActiveCDs do
            activeCDs[i]:Anchor(activeCDs[i-1], "LEFT")
        end
    end

    local fsrel, fspoints, fsx, fsy = nil, {"BOTTOM", "TOP"}, -50, TotemTimers.ActiveProfile.CooldownSpacing

    if TotemTimers.ActiveProfile.FlameShockDurationOnTop then
        fsrel = activeCDs[split].button
        if topRow % 2 == 0 then fsx = -30 end
    else
        fsrel = activeCDs[bottomRow == 0 and split or bottomSplit].button
        fspoints[1], fspoints[2] = fspoints[2], fspoints[1]
        fsy = -fsy
        local rowCount = bottomRow == 0 and topRow or bottomRow
        if rowCount % 2 == 0 then fsx = -30 end
    end

    FlameShockDuration.button:SetPoint(fspoints[1], fsrel, fspoints[2], fsx, fsy)

end

function TotemTimers.ActivateEnhanceCDs()
    TotemTimers.ConfigEnhanceCDs()
    TotemTimers.LayoutEnhanceCDs()
end

function TotemTimers.DeactivateEnhanceCDs()
    for k,v in pairs(cds) do
        v:Deactivate()
    end
    FlameShockDuration:Deactivate()
end

function TotemTimers.EnhanceCDEvents(self, event, spell)
    local settings = TotemTimers.ActiveProfile
    if event == "SPELL_UPDATE_COOLDOWN" and AvailableSpells[self.cdspell] then
		local start, duration, enable = GetSpellCooldown(self.cdspell)
        if (not start and not duration) then --or (duration <= 1.5 and not InCombatLockdown()) then 			
            self.timer:Stop(1)					
        else
            if duration <= 1.5 then
                self.timer:Stop(1)
            elseif duration > 1.5 then
                self.timer:Start(1,start+duration-GetTime(),duration)
            end
            CooldownFrame_Set(self.cooldown, start, duration, enable)
        end 
    elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then 
		if spell == self.glowSpell then
			ActionButton_ShowOverlayGlow(self)			
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then		
		if spell == self.glowSpell then
			ActionButton_HideOverlayGlow(self)
		end		
	end
end

local SearingIcon = SpellTextures[SpellIDs.Searing]
local MagmaIcon = SpellTextures[SpellIDs.Magma]
local FireElementalIcon = SpellTextures[SpellIDs.FireElemental]
function TotemTimers.FireTotemEvent(self,event,...)
    local element = ...
    if event == "PLAYER_TOTEM_UPDATE" then
        if element == 1 then
            local _, totem, startTime, duration, icon = GetTotemInfo(1)
            if icon == self.icon:GetTexture() and duration > 0 then
				self.icon:SetTexture(icon)
                self.timer:Start(1, duration)
            elseif self.timer.timers[1] > 0 then 
                self.timer:Stop(1)
            end
        end
    else
        -- TotemTimers.EnhanceCDEvents(self,event,...)
    end
end


function TotemTimers.ShieldChargeEvent(self, event, ...)
	if event == "UNIT_AURA" and select(1,...) =="player" then
		local name,_,texture,count,_,duration,endtime = UnitAura("player", ShieldName)
		if name then
			if role == 1 then
				self.timer:Start(1, count, 15)
			else
				self.timer:Start(1, endtime-GetTime(), duration)
			end
		elseif self.timer.timers[1]>0 then
			self.timer:Stop(1)
		end
	elseif event ~= "SPELL_UPDATE_COOLDOWN" then
        TotemTimers.EnhanceCDEvents(self,event,...)
    end
end


local FSAuraGUID = nil
local FSName, FSEv, FSSource, FSTarget, FSSpell, FSBuffType, FSDuration, FSExpires, FSID = nil

local function CheckFSBuff(self, unit)
	local _
	local fsFound = false	
	FSName = ""
	for i=1,40 do
        FSName,_,_,_,FSDuration,FSExpires,FSSource,_,_,FSID = UnitDebuff(unit, i)
        if FSName and FSName == FlameShockName and FSDuration and FSSource == "player" then
			self.timer:Start(1, -1 * GetTime() + FSExpires, FSDuration)
			fsFound = true
			break
        elseif not FSName then
            break
        end
	end
	if not fsFound then
		self.timer:Stop(1)
	end
end

function TotemTimers.FlameShockEvent(self,event,unit,...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _
        FSEv, _, _, FSSource, _, _, FSTarget, _, _, _, FSSpell = ...
		if FSEv == "UNIT_DIED" then
            if FSAuraGUID and FSTarget == FSAuraGUID then
                self.timer:Stop(1)
                FSAuraGUID = nil
            end
        end
    elseif (event == "PLAYER_TARGET_CHANGED" and UnitExists("target"))
	  or (event == "UNIT_AURA" and unit == "target") then
        FSAuraGUID = UnitGUID("target")
        CheckFSBuff(self, "target")
	elseif event == "PET_BATTLE_OPENING_START" then
		if self:IsShown() then
			self.shownBeforePet = true
			self:Hide()
		end
	elseif event == "PET_BATTLE_CLOSE" then
		if self.shownBeforePet then
			self:Show()
			self.shownBeforePet = false
		end
    end
end


local StormStrike = SpellNames[SpellIDs.StormStrike]

function TotemTimers.StormStrikeEvent(self, event, unit, ...)
    if (event == "UNIT_AURA" and unit == "target") or event == "PLAYER_TARGET_CHANGED" then
        if UnitExists("target") then
            for i = 1,40 do
                local name,_,_,_,duration,endtime = UnitDebuff("target", i)
                if name then
                    if name == StormStrike then
                        local timeleft = endtime - GetTime()
                        self.timer:StartBarTimer(timeleft, duration)
                        return
                     end
                else
                    break
                end
            end
        end
        if self.timer.barTimer>0 then
            self.timer:StopBarTimer()
        end
    else
        TotemTimers.EnhanceCDEvents(self, event, unit, ...)
    end
end


local Focused = 43339
local ElementalFocus = 16164
local ClearCasting = 16246
local ShockBuffActive = {}
function TotemTimers.ShockEvent(self, event, unit, ...)
    if event == "UNIT_AURA" and unit == "player" then
        for i = 1,40 do
            local name,_,_,_,duration,endtime,_,_,_,spellID = UnitBuff("player", i)
            if spellID then
                if (spellID == Focused or spellID == ElementalFocus or spellID == ClearCasting) then
                    if not ShockBuffActive[self.timer.nr] then
                        ShockBuffActive[self.timer.nr] = true
                        ActionButton_ShowOverlayGlow(self)
                    end
                    return
                 end
            else
                break
            end
        end
        if ShockBuffActive[self.timer.nr] then
            ShockBuffActive[self.timer.nr] = false
            ActionButton_HideOverlayGlow(self)
        end
    else
        TotemTimers.EnhanceCDEvents(self, event, unit, ...)
    end
end