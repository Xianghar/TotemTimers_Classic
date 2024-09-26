if select(2, UnitClass("player")) ~= "SHAMAN" then return end
if C_Seasons.GetActiveSeason() ~= 2 then return end

local _, TotemTimers = ...

local SpellIDs = TotemTimers.SpellIDs
local AvailableSpells = TotemTimers.AvailableSpells

local frame = CreateFrame("Frame")

local PowerSurgeName = GetSpellInfo(SpellIDs.PowerSurge)

local FindActionButtons = TotemTimers.FindActionButtons
local ShowButtonsOverlayGlow = TotemTimers.ShowButtonsOverlayGlow
local HideButtonsOverlayGlow = TotemTimers.HideButtonsOverlayGlow

local powerSurgeSpellsHeal = TotemTimers.PowerSurgeSpellsHeal
local powerSurgeSpellsDps = TotemTimers.PowerSurgeSpellsDps
local powerSurgeSpellsButtonsHeal = nil
local powerSurgeSpellsButtonsDps = nil

local powerSurgeBuffHeal = TotemTimers.SpellIDs.PowerSurgeBuffHeal
local powerSurgeBuffDps = TotemTimers.SpellIDs.PowerSurgeBuffDps

local powerSurgeHealActive = false
local powerSurgeDpsActive = false

local function IDPredicate(auraIDToFind, _, _, _,_,_,_,_,_,_,_,_,auraID)
    return auraIDToFind == auraID;
end

frame:SetScript("OnEvent", function(self, event, ...)
    local _,_,healCount = AuraUtil.FindAura(IDPredicate, "player", "HELPFUL", powerSurgeBuffHeal)
    local _,_,dpsCount = AuraUtil.FindAura(IDPredicate, "player", "HELPFUL", powerSurgeBuffDps)

    local startAura = false

    if dpsCount and not powerSurgeDpsActive then
        powerSurgeDpsActive = true
        startAura = true
        XiTimers.PlayWarning(self, "PowerSurge")
        if TotemTimers.ActiveProfile.OverlayGlow then
            powerSurgeSpellsButtonsDps = FindActionButtons(powerSurgeSpellsDps)
            ShowButtonsOverlayGlow(powerSurgeSpellsButtonsDps)
        end
    end
    if not dpsCount then
        powerSurgeDpsActive = false
        if powerSurgeSpellsButtonsDps and #powerSurgeSpellsButtonsDps > 0 then
            HideButtonsOverlayGlow(powerSurgeSpellsButtonsDps)
            powerSurgeSpellsButtonsDps = nil
        end
    end

    if healCount and not powerSurgeHealActive then
        powerSurgeHealActive = true
        startAura = true
        XiTimers.PlayWarning(self, "PowerSurge")
        if TotemTimers.ActiveProfile.OverlayGlow then
            powerSurgeSpellsButtonsHeal = FindActionButtons(powerSurgeSpellsHeal)
            ShowButtonsOverlayGlow(powerSurgeSpellsButtonsHeal)
        end
    end
    if not healCount then
        powerSurgeHealActive = false
        if powerSurgeSpellsButtonsHeal and #powerSurgeSpellsButtonsHeal > 0 then
            HideButtonsOverlayGlow(powerSurgeSpellsButtonsHeal)
            powerSurgeSpellsButtonsHeal = nil
        end
    end

    if startAura then
        if powerSurgeHealActive then
            TotemTimers.MaelstromIcon.icon:SetTexture("Interface/AddOns/TotemTimers/textures/high_tide")
        else
            TotemTimers.MaelstromIcon.icon:SetTexture("Interface/AddOns/TotemTimers/textures/impact")
        end
        TotemTimers.MaelstromIcon:Show()
        TotemTimers.MaelstromIcon.icon.AnimGroup:Play()
    end

    if not healCount and not dpsCount then
        TotemTimers.MaelstromIcon:Hide()
        TotemTimers.MaelstromIcon.icon.AnimGroup:Stop()
    end
end)

function TotemTimers.EnablePowerSurge(enable)
    if AvailableSpells[SpellIDs.PowerSurge] and enable then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
end

