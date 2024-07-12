if select(2, UnitClass("player")) ~= "SHAMAN" then return end
if C_Seasons.GetActiveSeason() ~= 2 then return end

local _, TotemTimers = ...

local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers", true)

local SpiritAlphaID = TotemTimers.SpellIDs.SpiritAlpha
local SpiritAlphaName = TotemTimers.SpellNames[SpiritAlphaID]

local SACastTarget = nil
local SACastID = nil
local SATarget = nil

local SpiritAlphaTooltip = XiTimersTooltip:new()

local function InitSpiritAlpha()
    local timer = nil
    for t = 1,#TotemTimers.LongCooldowns do
        if TotemTimers.LongCooldowns[t].spell == SpiritAlphaID then
            timer = TotemTimers.LongCooldowns[t]
            break
        end
    end
    if not timer then return end

    timer.button.tooltip = SpiritAlphaTooltip:new(timer.button)

    timer.name = timer.button:CreateFontString()
    timer.name:SetPoint("TOP", timer.button, 0, 2)
    timer.name:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")

    timer.button:SetAttribute("unit2", "target")
    timer.button:SetAttribute("unit3", "player")
    timer.button:SetAttribute("spell*", SpiritAlphaName)
    timer.button:SetAttribute("type*", "spell")
    timer.button:RegisterForClicks("AnyDown")
end

table.insert(TotemTimers.Modules, InitSpiritAlpha)

local splitString = TotemTimers.splitString

function TotemTimers.SpiritAlphaEvent(self, event, unit, ...)
    if unit == "player" then
        if event == "UNIT_SPELLCAST_SENT" then
            local target, castID, spellID = ...
            if spellID == SpiritAlphaID then
                SACastTarget = target
                SACastID = castID
            end
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local castID = ...
            if castID == SACastID then
                SATarget = SACastTarget
                SACastTarget = nil
                SACastID = nil
                self:UnregisterEvent("UNIT_AURA")
                self:RegisterUnitEvent("UNIT_AURA", SATarget)
                self.timer.name:SetText(splitString(SATarget))
                if not InCombatLockdown() then
                    self:SetAttribute("*unit1", SATarget)
                end
                if GameTooltip:IsVisible() and GameTooltip:IsOwned(self) then
                    self.tooltip:Show()
                end
            end
        end
    end
    if event == "UNIT_AURA"  and SATarget then
        local _, _, _, count, duration, expires = AuraUtil.FindAuraByName(SpiritAlphaName, SATarget, "HELPFUL")
        local timer = self.timer
        if duration and expires then
            timer:Start(1, expires - GetTime(), duration)
            timer.buffIsActive = true
        else
            timer:Stop(1)
            timer.buffIsActive = false
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if (SATarget) then
            self:SetAttribute("*unit1", SATarget)
        end
    end
end

function SpiritAlphaTooltip:SetText()
    local spell = self.button:GetAttribute("spell1")
    if not spell then return end

    self:SetSpell(spell)

    GameTooltip:AddLine(" ")
    local target = self.button:GetAttribute("*unit1")
    if target then
        GameTooltip:AddLine("Leftclick: " .. target, self.r,self.g,self.b,1)
    else
        GameTooltip:AddLine(L["Leftclick: target"], self.r,self.g,self.b,1);
    end
    GameTooltip:AddLine(L["Rightclick: target"],self.r,self.g,self.b,1)
    GameTooltip:AddLine(L["Middleclick: self"],self.r,self.g,self.b,1)
end