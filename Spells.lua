if select(2, UnitClass("player")) ~= "SHAMAN" then
    return
end

local _, TotemTimers = ...

TotemTimers.AvailableSpells = {}
TotemTimers.AvailableTalents = {}

TotemTimers.SpellTextures = {}
TotemTimers.SpellNames = {}
TotemTimers.NameToSpellID = {}
TotemTimers.TextureToSpellID = {}
TotemTimers.ForceSpellNames = {}

local SpellIDs = TotemTimers.SpellIDs
local SpellIDsForceNames = TotemTimers.SpellIDsForceNames or {}
local ForceSpellNames = TotemTimers.ForceSpellNames
local AvailableSpells = TotemTimers.AvailableSpells
local SpellNames = TotemTimers.SpellNames
local SpellTextures = TotemTimers.SpellTextures
local NameToSpellID = TotemTimers.NameToSpellID
local TextureToSpellID = TotemTimers.TextureToSpellID


-- populate SpellNames and NameToSpellID with unranked spells first
-- TT inits with that info and upgrades ranks later when ranks are available

for _, spellID in pairs(SpellIDs) do
    local name, _, texture = GetSpellInfo(spellID)
    if name then
        NameToSpellID[name] = spellID
        SpellNames[spellID] = name
        SpellTextures[spellID] = texture
        TextureToSpellID[texture] = spellID
        if (spellID > 400000 or SpellIDsForceNames[spellID]) then
            ForceSpellNames[name] = true
        end
    end
    AvailableSpells[spellID] = IsPlayerSpell(spellID) or IsSpellKnownOrOverridesKnown(spellID)
end

if LE_EXPANSION_LEVEL_CURRENT > LE_EXPANSION_BURNING_CRUSADE then
    NameToSpellID["Totemic Call"] = SpellIDs.TotemicCall
    --small workaround for Totemic Call renamed Totemic Recall in WOTLK
end


-- get ranked spell names from spell book
function TotemTimers.GetSpells()
    wipe(AvailableSpells)
    for _, spellID in pairs(SpellIDs) do
        AvailableSpells[spellID] = IsPlayerSpell(spellID) or IsSpellKnownOrOverridesKnown(spellID)
    end
end

function TotemTimers.GetTalents()
    wipe(TotemTimers.AvailableTalents)
end

if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then

    TotemTimers.GetTalents = function()
        wipe(TotemTimers.AvailableTalents)
        TotemTimers.AvailableTalents.TotemicMastery = select(5, GetTalentInfo(3, 8)) * 10
        TotemTimers.AvailableTalents.DualWield = AvailableSpells[SpellIDs.DualWield]
        TotemTimers.AvailableTalents.Maelstrom = AvailableSpells[SpellIDs.Maelstrom]
    end

elseif LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_BURNING_CRUSADE then

    TotemTimers.GetTalents = function()
        wipe(TotemTimers.AvailableTalents)
        TotemTimers.AvailableTalents.TotemicMastery = select(5, GetTalentInfo(3, 8)) * 10
        TotemTimers.AvailableTalents.DualWield = select(5, GetTalentInfo(2, 18)) > 0
    end

elseif LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_WRATH_OF_THE_LICH_KING then

    TotemTimers.GetTalents = function()
        wipe(TotemTimers.AvailableTalents)
        TotemTimers.AvailableTalents.TotemicMastery = 0
        TotemTimers.AvailableTalents.DualWield = select(5, GetTalentInfo(2, 17)) > 0
        TotemTimers.AvailableTalents.Maelstrom = select(5, GetTalentInfo(2,24)) > 0
    end

elseif LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_CATACLYSM then
    TotemTimers.GetTalents = function()
        wipe(TotemTimers.AvailableTalents)
        TotemTimers.AvailableTalents.TotemicMastery = 0
        TotemTimers.AvailableTalents.DualWield = TotemTimers.Specialization == 2
        TotemTimers.AvailableTalents.Maelstrom = select(5, GetTalentInfo(2,11)) > 0
    end
end

function TotemTimers.GetBaseSpellID(spell)
    local name = GetSpellInfo(spell)
    if not name then
        return spell
    end
    return NameToSpellID[name] or spell
end

local function UpdateSpellRank(spell, useName)
    local name = GetSpellInfo(spell)

    return useName and name or select(7, GetSpellInfo(name))
end

if LE_EXPANSION_LEVEL_CURRENT < 2 then
    UpdateSpellRank = function(spell, useName)
        local name = GetSpellInfo(spell)

        if name == SpellNames[SpellIDs.Windfury] and TotemTimers.ActiveProfile.WindfuryDownrank then
            if useName then
                return SpellNames[SpellIDs.Windfury] .. "(" .. GetSpellSubtext(SpellIDs.Windfury) .. ")"
            else
                return SpellIDs.Windfury
            end
        end
        -- ... or spell is a workaround for SOD GetSpellInfo not working immediately on login
        return (useName or ForceSpellNames[name]) and name or (select(7, GetSpellInfo(name)) or spell)
    end
end

TotemTimers.UpdateSpellRank = UpdateSpellRank

local function UpdateRank(button)
    for i = 1, 3 do
        for _, type in pairs({ "*spell", "spell", "doublespell" }) do
            local spell = button:GetAttribute(type .. i)
            if spell then
                local newRank = UpdateSpellRank(spell, (type == "doublespell") or button.useSpellNames)
                -- lower rank for ft for ft/ft-button on weapon tracker
                if type == "doublespell" and i == 1 and newRank == SpellNames[SpellIDs.FlametongueWeapon] then
                    local rank = GetSpellSubtext(SpellNames[SpellIDs.FlametongueWeapon])
                    if rank then
                        local lowerRank = string.gsub(rank, "(%d+)", function(rank) return tostring(tonumber(rank) -1) end)
                        newRank = SpellNames[SpellIDs.FlametongueWeapon].."("..lowerRank..")"
                    end
                end
                if newRank then
                    button:SetAttribute(type .. i, newRank)
                end
            end
        end
    end
end

TotemTimers.UpdateRank = UpdateRank

function TotemTimers.UpdateSpellRanks()
    for _, timer in pairs(XiTimers.timers) do
        UpdateRank(timer.button)
        if timer.actionBar then
            for _, actionButton in pairs(timer.actionBar.buttons) do
                UpdateRank(actionButton)
            end
        end
    end
    if TotemTimers.MaelstromButton then
        UpdateRank(TotemTimers.MaelstromButton)
    end
end

TotemTimers.Specialization = 2

-- get specialization, if no points are spent (e.g. talents reset) do not change specialization

if WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
    function TotemTimers.GetSpecialization()
        local spec = GetPrimaryTalentTree()
        if spec and spec > 0 then
            TotemTimers.Specialization = spec
        elseif not TotemTimers.Specialization then
            TotemTimers.Specialization = 2
        end
        TotemTimers.AddDebug("Spec: "..TotemTimers.Specialization)
    end
else

    function TotemTimers.GetSpecialization()
        local pointsSpent = 0
        for i=1,3 do
            local points = select((WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) and 5 or 3, GetTalentTabInfo(i))
            if points > pointsSpent then
                pointsSpent = points
                TotemTimers.Specialization = i
            end
        end
        TotemTimers.AddDebug("Spec: "..TotemTimers.Specialization)
    end

end

function TotemTimers.ChangedTalents()
    TotemTimers.GetSpecialization()
    TotemTimers.GetSpells()
    TotemTimers.GetTalents()
    TotemTimers.SelectActiveProfile()
    TotemTimers.ExecuteProfile()
    TotemTimers.UpdateSpellRanks()

    if TotemTimers.SpellUpdaters then
        for _, updater in pairs(TotemTimers.SpellUpdaters) do
            updater()
        end
    end
end
