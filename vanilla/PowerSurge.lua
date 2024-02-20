if select(2, UnitClass("player")) ~= "SHAMAN" then return end
if C_Seasons.GetActiveSeason() ~= 2 then return end

local _, TotemTimers = ...

local SpellIDs = TotemTimers.SpellIDs
local AvailableSpells = TotemTimers.AvailableSpells

local frame = CreateFrame("Frame")

local PowerSurgeName = GetSpellInfo(SpellIDs.PowerSurge)

local powerSurgeActive = false

local FindActionButtons = TotemTimers.FindActionButtons
local ShowButtonsOverlayGlow = TotemTimers.ShowButtonsOverlayGlow
local HideButtonsOverlayGlow = TotemTimers.HideButtonsOverlayGlow

local powerSurgeSpells = TotemTimers.PowerSurgeSpells
local powerSurgeSpellsButtons = nil


frame:SetScript("OnEvent", function(self, event, ...)
    local _,_,count = AuraUtil.FindAuraByName(PowerSurgeName, "player", "HELPFUL")
    if count and not powerSurgeActive then
        TotemTimers.MaelstromIcon:Show()
        TotemTimers.MaelstromIcon.icon.AnimGroup:Play()
        XiTimers.PlayWarning(self, "PowerSurge")
        if TotemTimers.ActiveProfile.OverlayGlow then
            powerSurgeSpellsButtons = FindActionButtons(powerSurgeSpells)
            ShowButtonsOverlayGlow(powerSurgeSpellsButtons)
        end
    end
    if not count then
        TotemTimers.MaelstromIcon:Hide()
        TotemTimers.MaelstromIcon.icon.AnimGroup:Stop()
        powerSurgeActive = false
        if powerSurgeSpellsButtons and #powerSurgeSpellsButtons > 0 then
            HideButtonsOverlayGlow(powerSurgeSpellsButtons)
            powerSurgeSpellsButtons = nil
        end
    end
end)

function TotemTimers.EnablePowerSurge(enable)
    if AvailableSpells[SpellIDs.PowerSurge] and enable then
        TotemTimers.MaelstromIcon.icon:SetTexture("Interface/AddOns/TotemTimers/textures/impact")
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
end

