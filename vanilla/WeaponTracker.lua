if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers")

local Timers = XiTimers.timers
local SpellNames = TotemTimers.SpellNames
local SpellIDs = TotemTimers.SpellIDs
local SpellTextures = TotemTimers.SpellTextures
local AvailableSpells = TotemTimers.AvailableSpells

local weapon = nil

local function Init()
    weapon = XiTimers:new(1)

    weapon.button.icons[1]:SetTexture(SpellTextures[SpellIDs.RockbiterWeapon])
    weapon.button.anchorframe = TotemTimers_TrackerFrame
    weapon.button:SetScript("OnEvent", TotemTimers.WeaponEvent)
    --weapon.events[1] = "COMBAT_LOG_EVENT_UNFILTERED"
    --weapon.events[2] = "UNIT_INVENTORY_CHANGED"
    --weapon.events[3] = "CHARACTER_POINTS_CHANGED"
    weapon.events[5] = "UNIT_SPELLCAST_SUCCEEDED"
    -- weapon.events[6] = "UNIT_AURA"
    --weapon.events[7] = "PLAYER_TALENT_UPDATE"
    weapon.timeStyle = "blizz"
    weapon.button:SetAttribute("*type*", "spell")
    weapon.button:SetAttribute("ctrl-spell1", ATTRIBUTE_NOOP)
    weapon.button:RegisterEvent("PLAYER_ALIVE")
    weapon.Update = TotemTimers.WeaponUpdate
    weapon.button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    weapon.timerBars[1]:SetMinMaxValues(0,1800)
    weapon.flashall = true
    weapon.Activate = function(self)
        XiTimers.Activate(self)
        if not TotemTimers.ActiveProfile.WeaponTracker then self.button:Hide() end
    end

    weapon.actionBar = TTActionBars:new(7, weapon.button, nil, TotemTimers_TrackerFrame, "weapontimer")

    weapon.button.tooltip = TotemTimers.Tooltips.WeaponTimer:new(weapon.button)

    weapon.button.SaveLastEnchant = function(self, name)
        if name == "spell1" then TotemTimers.ActiveProfile.LastWeaponEnchant = self:GetAttribute("spell1")
        elseif name == "spell2" or name == "spell3" then
            TotemTimers.ActiveProfile.LastWeaponEnchant2 = self:GetAttribute("spell2") or self:GetAttribute("spell3")
        elseif name == "doublespell2" then
            local ds2 = self:GetAttribute("doublespell2")
            if ds2 then
                if ds2 == SpellNames[SpellIDs.FlametongueWeapon] then
                    TotemTimers.ActiveProfile.LastWeaponEnchant = 5
                elseif ds2 == SpellNames[SpellIDs.FrostbrandWeapon] then
                    TotemTimers.ActiveProfile.LastWeaponEnchant = 6
                end
            end
        end
    end
    weapon.button:SetAttribute("_onattributechanged", [[ if name == "spell1" or name == "doublespell1" or name == "doublespell2" or name == "spell2" or name == "spell3"then
                                                             control:CallMethod("SaveLastEnchant", name)
                                                         end]])

    weapon.button:WrapScript(weapon.button, "PostClick", [[ if button == "LeftButton" then
                                                                local ds1 = self:GetAttribute("doublespell1")
                                                                if ds1 then
                                                                    if IsControlKeyDown() or self:GetAttribute("ds") ~= 1 then
                                                                        self:SetAttribute("macrotext", "/cast "..ds1.."\n/use 16")
																		self:SetAttribute("ds",1)
                                                                    else
                                                                        self:SetAttribute("macrotext", "/cast "..self:GetAttribute("doublespell2").."\n/use 17")
																		self:SetAttribute("ds",2)
                                                                    end
                                                                end
                                                           end]])

    weapon.button:SetAttribute("ctrl-type1", "cancelaura")
    weapon.button:SetAttribute("ctrl-target-slot1", GetInventorySlotInfo("MainHandSlot"))
    weapon.button:SetAttribute("ctrl-type2", "cancelaura")
    weapon.button:SetAttribute("ctrl-target-slot2", GetInventorySlotInfo("SecondaryHandSlot"))
    weapon.button:SetScript("OnDragStop", function(self)
        XiTimers.StopMoving(self)
        if not InCombatLockdown() then self:SetAttribute("hide", true) end
        TotemTimers.ProcessSetting("WeaponBarDirection")
    end)
    weapon.nobars = true
    weapon.Stop = function(self,timer)
        XiTimers.Stop(self,timer)
        self.button.bar:Show()
    end
    weapon.button.bar:Show()
    weapon.button.bar:SetStatusBarColor(0.7,1,0.7,0.7)

    weapon.Start = function(self, ...)
        XiTimers.Start(self, ...)
        self.running = 1
    end
    weapon.Stop = function(self, ...)
        XiTimers.Stop(self, ...)
        self.running = 1
    end
    weapon.running = 1
    TotemTimers.WeaponTracker = weapon
    TotemTimers.SetWeaponTrackerSpells()
end

table.insert(TotemTimers.Modules, Init)


function TotemTimers.SetWeaponTrackerSpells()
    weapon.actionBar:ResetSpells()
    if  AvailableSpells[SpellIDs.WindfuryWeapon] then
        weapon.actionBar:AddSpell(SpellNames[SpellIDs.WindfuryWeapon])
    end
    if AvailableSpells[SpellIDs.RockbiterWeapon] then
        weapon.actionBar:AddSpell(SpellNames[SpellIDs.RockbiterWeapon])
    end
    if  AvailableSpells[SpellIDs.FlametongueWeapon] then
        weapon.actionBarr:AddSpell(SpellNames[SpellIDs.FlametongueWeapon])
    end
    if  AvailableSpells[SpellIDs.FrostbrandWeapon] then
        weapon.actionBar:AddSpell(SpellNames[SpellIDs.FrostbrandWeapon])
    end
end

table.insert(TotemTimers.SpellUpdaters, TotemTimers.SetWeaponTrackerSpells)

local GetWeaponEnchantInfo = GetWeaponEnchantInfo

local Enchanted, CastEnchant, CastTexture


local function SetWeaponEnchantTextureAndMsg(self, enchant, texture, nr)
    if nr == 1 then TotemTimers.ActiveProfile.LastMainEnchants[mainHandWeapon] = {enchant, texture}
    else TotemTimers.ActiveProfile.LastOffEnchants[offHandWeapon] = {enchant, texture} end
    self.icons[nr]:SetTexture(texture)
    self.timer.warningIcons[nr] = texture
    self.timer.warningSpells[nr] = enchant
    self.timer.expirationMsgs[nr] = "Weapon"
end

function TotemTimers.WeaponUpdate(self, elapsed)
    local enchant, expiration = GetWeaponEnchantInfo()
    if enchant then
        if expiration/1000 > self.timers[1] then
            self:Start(1, expiration/1000, 300)
            if Enchanted then
                Enchanted = nil
                SetWeaponEnchantTextureAndMsg(self.button, CastEnchant, CastTexture, 1)
            end
        end
        if expiration == 0 then
            self:Stop(1)
        else
            self.timers[1] = expiration/1000
        end
    elseif self.timers[1] > 0 then
        self:Stop(1)
    end
    XiTimers.Update(self, 0)
end

local function getWeapons()
    lastMhWeapon = mainHandWeapon
    mainHandWeapon = GetInventoryItemLink("player", 16)
    if mainHandWeapon then  mainHandWeapon = tonumber(select(3,string.find(mainHandWeapon, "item:(%d+):"))) else mainHandWeapon = 0 end
    TotemTimers.MainHand = mainHandWeapon
end


local WeaponBuffs = {SpellNames[SpellIDs.WindfuryWeapon], SpellNames[SpellIDs.RockbiterWeapon],
                     SpellNames[SpellIDs.FlametongueWeapon], SpellNames[SpellIDs.FrostbrandWeapon], SpellNames[SpellIDs.EarthlivingWeapon]}
local lastWeaponBuffCast

function TotemTimers.WeaponEvent(self, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" and select(1,...) == "player" then
        local spell = select(3, ...)
        local spellName = GetSpellInfo(spell)
        for k,v in pairs(WeaponBuffs) do
            if v == spellName then
                getWeapons()
                lastWeaponBuffCast = v
                CastTexture = GetSpellTexture(lastWeaponBuffCast)
                CastEnchant = spellName
                Enchanted = true
                break
            end
        end
        local start, duration, enable = GetSpellCooldown(SpellNames[SpellIDs.RockbiterWeapon])
        if start and duration and (not self.timer.timerOnButton or self.timer.timers[1]<=0) then
            CooldownFrame_Set(self.cooldown, start, duration, enable)
        end
    end
end