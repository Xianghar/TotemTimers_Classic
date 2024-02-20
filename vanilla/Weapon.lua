if select(2, UnitClass("player")) ~= "SHAMAN" then
    return
end

if C_Seasons.GetActiveSeason() ~= 2 then return end

local weapon = nil
local SpellIDs = TotemTimers.SpellIDs
local AvailableSpells = TotemTimers.AvailableSpells
local AvailableTalents = TotemTimers.AvailableTalents

local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers")
local r = 0
local g = 0.9
local b = 1



local augmentWeaponTracker = function()
    weapon = TotemTimers.WeaponTracker
    weapon.button:SetAttribute("_onattributechanged", [[
        if string.sub(name, 1, 5) == "spell" or name == "doublespell1" or name == "doublespell2" then
            control:CallMethod("SaveLastEnchant", name)
        end
        if string.sub(name, 1, 5) == "spell" then
            local prefix = ''
            if name == "spell2" or name == "spell3" then
                prefix = "shift-"
            elseif name == "spell4" then
                prefix = "alt-"
            elseif name == "spell5" then
                prefix = "alt-ctrl-"
            end
            self:SetAttribute(prefix.."type1", "macro")
            self:SetAttribute(prefix.."type2", "macro")
            self:SetAttribute(prefix.."macrotext1", "/cast [@none] "..value.."\n/use 16\n/click StaticPopup1Button1")
            self:SetAttribute(prefix.."macrotext2", "/cast [@none] "..value.."\n/use 17\n/click StaticPopup1Button1")
            if name == "spell4" then self:SetAttribute("spell5", value) end
        end
        if name == "doublespell1" or name == "doublespell2" then
            if self:GetAttribute(name) then self:SetAttribute("ds", 1) end
        elseif name == "ds" then
            local ds = self:GetAttribute("ds")
            self:SetAttribute("macrotext1", "/cast [@none] "..self:GetAttribute("doublespell"..ds).."\n/use "..(15+ds).."\n/click StaticPopup1Button1")
        end
    ]]);
    weapon.button.useSpellNames = true
    for i = 1,weapon.actionBar.numbuttons do
        weapon.actionBar.buttons[i].useSpellNames = true
    end

    weapon.button:SetScript("OnEvent", function(self, event, slot, ...)
        if event == "PLAYER_EQUIPMENT_CHANGED" and slot == 17 then
            TotemTimers.SetNumWeaponTimers()
        end
        if (slot == 16) then weapon.slotChanged[1] = true
        elseif (slot == 17) then weapon.slotChanged[2] = true
        end
    end)
end

table.insert(TotemTimers.Modules, augmentWeaponTracker)

TotemTimers.SetWeaponTrackerSpells = function()
    weapon.actionBar:ResetSpells()
    for i = 1,weapon.actionBar.numbuttons do
        local button = weapon.actionBar.buttons[i]
        button.icons[1]:ClearAllPoints()
        button.icons[2]:ClearAllPoints()
        button.icons[1]:SetPoint("LEFT", button)
        button.icons[2]:SetPoint("LEFT", button, "CENTER")
    end

    for _,spellID in pairs({SpellIDs.WindfuryWeapon, SpellIDs.RockbiterWeapon,
                            SpellIDs.FlametongueWeapon, SpellIDs.FrostbrandWeapon, SpellIDs.EarthlivingWeapon}) do
        if AvailableSpells[spellID] then
            weapon.actionBar:AddSpell(spellID, true)
        end
    end

    if AvailableTalents.DualWield then
        if AvailableSpells[SpellIDs.WindfuryWeapon] and AvailableSpells[SpellIDs.FlametongueWeapon] then
            weapon.actionBar:AddDoubleSpell(SpellIDs.WindfuryWeapon, SpellIDs.FlametongueWeapon)
        end
        if AvailableSpells[SpellIDs.WindfuryWeapon] and AvailableSpells[SpellIDs.FrostbrandWeapon] then
            weapon.actionBar:AddDoubleSpell(SpellIDs.WindfuryWeapon, SpellIDs.FrostbrandWeapon)
        end
        if AvailableSpells[SpellIDs.WindfuryWeapon] and AvailableSpells[SpellIDs.RockbiterWeapon] then
            weapon.actionBar:AddDoubleSpell(SpellIDs.WindfuryWeapon, SpellIDs.RockbiterWeapon)
        end
        --[[if AvailableSpells[SpellIDs.FlametongueWeapon]
                and SpellIDs.FlametongueWeapon  ~= select(7, GetSpellInfo(SpellNames[SpellIDs.FlametongueWeapon])) then
            weapon.actionBar:AddDoubleSpell(SpellIDs.FlametongueWeapon, SpellIDs.FlametongueWeapon)
            --set ft-1/ft-button visually apart from ft-button by switching texture positions
            local button = weapon.actionBar.buttons[weapon.actionBar.numspells]
            button.icons[1]:ClearAllPoints()
            button.icons[2]:ClearAllPoints()
            button.icons[1]:SetPoint("LEFT", button, "CENTER")
            button.icons[2]:SetPoint("LEFT", button)
        end]]
    end
end


TotemTimers.Tooltips.WeaponBar.SetText = function(self)
    local button = self.button

    local spell = button:GetAttribute("*spell1")
    if not spell then spell = button:GetAttribute("spell1") end
    local doublespell = button:GetAttribute("doublespell1")

    if not doublespell then
        if spell then self:SetSpell(spell) end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Leftclick to cast spell"],r,g,b,1)
        GameTooltip:AddLine(L["Rightclick to assign to MH/OH on left- and rightclick"],r,g,b,1)
        GameTooltip:AddLine(L["Shift-Rightclick to assign to MH/OH on shift-left and shift-rightclick"],r,g,b,1)
        GameTooltip:AddLine(L["Alt-Rightclick to assign to MH/OH on alt-left and alt-rightclick"],r,g,b,1)
    else
        --GameTooltip:ClearLines()
        GameTooltip:AddLine(doublespell,1,1,1)
        GameTooltip:AddLine(button:GetAttribute("doublespell2"),1,1,1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Rightclick to assign to weapon button leftclick"],r,g,b,1)
    end
end

TotemTimers.Tooltips.WeaponTimer.SetText = function(self)
    local button = self.button

    for i = 1, 2 do
        if button.timer.timers[i] and button.timer.timers[i] > 0 then
            GameTooltip:AddLine(button.timer["enchant"..i])
        end
    end

    GameTooltip:AddLine(" ")

    local spell = button:GetAttribute("spell1")
    if spell and not button:GetAttribute("doublespell1") then
        GameTooltip:AddLine(L["Left button for main hand, right button for off hand"],r,g,b,1)
        local texture = select(3, GetSpellInfo(spell))
        GameTooltip:AddLine(format(L["LB/RB: %s"], "|T"..texture..":16:16|t"),r,g,b,1)
    else
        local ds = button:GetAttribute("ds")
        if ds then
            local ds1 = button:GetAttribute("doublespell1")
            local ds2 = button:GetAttribute("doublespell2")
            local t1 = select(3, GetSpellInfo(ds1))
            local t2 = select(3, GetSpellInfo(ds2))
            --if ds == 2 then ds1, ds2 = ds2, ds1 end
            if t1 and t2 then
                GameTooltip:AddLine(format(L["LB: %s/%s"], "|T"..t1..":16:16|t", "|T"..t2..":16:16|t"),r,g,b,1)
                --GameTooltip:AddLine(format(L["Leftclick to cast %s"], ds1),r,g,b,1)
                --GameTooltip:AddLine(format(L["Next leftclick casts %s"], ds2),r,g,b,1)
            end
        end
    end
    spell = button:GetAttribute("spell2")
    if spell then
        local texture = select(3, GetSpellInfo(spell))
        GameTooltip:AddLine(format(L["Shift-LB/RB: %s"], "|T"..texture..":16:16|t"),r,g,b,1)
    end
    spell = button:GetAttribute("spell4")
    if spell then
        local texture = select(3, GetSpellInfo(spell))
        GameTooltip:AddLine(format(L["Alt-LB/RB: %s"], "|T"..texture..":16:16|t"),r,g,b,1)
    end
end


for i = 1,#TotemTimers.SpellUpdaters do
    if TotemTimers.SpellUpdaters[i] == TotemTimers.SetNumWeaponTimers then
        table.remove(TotemTimers.SpellUpdaters, i)
        break
    end
end

TotemTimers.SetNumWeaponTimers = function()
    local dualwield = AvailableTalents.DualWield and GetInventoryItemID("player", 17) and not IsEquippedItemType("INVTYPE_SHIELD")
    if not weapon then return end
    weapon.handsToCheck = dualwield and 2 or 1
    TotemTimers.SetDoubleTexture(weapon.button, dualwield, true)
    weapon.numtimers = dualwield and 2 or 1
    weapon:SetTimerBarPos(weapon.timerBarPos)
    if not dualwield then weapon:Stop(2) end
end

table.insert(TotemTimers.SpellUpdaters, TotemTimers.SetNumWeaponTimers)


