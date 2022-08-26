if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local addon, TotemTimers = ...

TotemTimers.AvailableSpells = {}
TotemTimers.AvailableSpellIDs = {}
TotemTimers.AvailableTalents = {}

TotemTimers.SpellTextures = {}
TotemTimers.SpellNames = {}
TotemTimers.NameToSpellID = {}
TotemTimers.TextureToSpellID = {}
TotemTimers.RankedNameToSpellID = {}
TotemTimers.SpellIDsMaxRank = {}
TotemTimers.RankToSpellID = {}

local SpellIDs = TotemTimers.SpellIDs
local AvailableSpells = TotemTimers.AvailableSpells
local SpellNames = TotemTimers.SpellNames
local SpellTextures = TotemTimers.SpellTextures
local NameToSpellID = TotemTimers.NameToSpellID
local TextureToSpellID = TotemTimers.TextureToSpellID
local RankedNameToSpellID = TotemTimers.RankedNameToSpellID
local SpellIDsMaxRank = TotemTimers.SpellIDsMaxRank
local RankToSpellID = TotemTimers.RankToSpellID

local gsub = gsub
function TotemTimers.StripRank(spell)
    local stripped = gsub(spell, "%(.*%)", "")
    return stripped
end

-- populate SpellNames and NameToSpellID with unranked spells first
-- TT inits with that info and upgrades ranks later when ranks are available

for _, spellID in pairs(SpellIDs) do
    local name,_,texture = GetSpellInfo(spellID)
    if name then
        NameToSpellID[name] = spellID
        SpellNames[spellID] = name
        SpellTextures[spellID] = texture
        TextureToSpellID[texture] = spellID
    end
    AvailableSpells[spellID] = IsPlayerSpell(spellID)
end

local WindfuryName = GetSpellInfo(SpellIDs.Windfury)

-- get ranked spell names from spell book
function TotemTimers.GetSpells()
    wipe(AvailableSpells)
    local index = 1
    local windfuryFound = false
    while true do
        local name, rank, rankedSpellID = GetSpellBookItemName(index, BOOKTYPE_SPELL)
        if not name then break end
        local spellID = NameToSpellID[name]
        if spellID then
            AvailableSpells[spellID] = true
            if rank and string.find(rank, "%d") then
                SpellIDsMaxRank[spellID] = rankedSpellID
                RankToSpellID[rankedSpellID] = spellID
                SpellNames[rankedSpellID] = name
                --[[local rankedName = name.."("..rank..")"
                NameToSpellID[rankedName] = spellID
                SpellNames[spellID] = rankedName
                RankedNameToSpellID[rankedName] = rankedSpellID
                if not windfuryFound and name == WindfuryName then
                    TotemTimers.WindfuryRank1 = rankedName
                    windfuryFound = true
                end]]
            end
        end
        index = index + 1
    end
end


local SpellNames = TotemTimers.SpellNames
local SpellIDs = TotemTimers.SpellIDs
local NameToSpellID = TotemTimers.NameToSpellID
local XiTimers = XiTimers

--[[ local function GetSpellTab(tab)
    local _, _, offset, numSpells = GetSpellTabInfo(tab)
    local AvailableSpells = TotemTimers.AvailableSpells
    for s = offset + 1, offset + numSpells do 
        local spelltype, spell = GetSpellBookItemInfo(s, BOOKTYPE_SPELL)
        if spelltype == "SPELL" then
            AvailableSpells[spell] = true
        end
    end
end  ]]

local GetSpellInfo = GetSpellInfo
local IsPlayerSpell = IsPlayerSpell


--[[function TotemTimers.GetSpells()
    local AvailableSpells = TotemTimers.AvailableSpells
    wipe(AvailableSpells)
    for _,s in pairs(SpellIDs) do
        -- get spell info by name, returns spell info of the spell with the highest rank,
        -- if that spell is learned; check with IsPlayerSpell probably not necessary anymore
        -- but stays in just in case
        local name,_,_,_,_,_,id = GetSpellInfo(SpellNames[s])
        if id ~= nil then
		    AvailableSpells[s] = IsPlayerSpell(id)
		end
    end
    return true
end]]

function TotemTimers.GetTalents()
    wipe(TotemTimers.AvailableTalents)
    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        TotemTimers.AvailableTalents.TotemicMastery = 0
        return
    end
    TotemTimers.AvailableTalents.TotemicMastery = select(5, GetTalentInfo(3,8)) * 10
    TotemTimers.AvailableTalents.DualWield = select(5, GetTalentInfo(2, 18)) > 0

    --if select(5, GetTalentInfo(2,17))>0 then TotemTimers.AvailableTalents.Maelstrom = true end
    --if select(5, GetTalentInfo(1,18))>0 then TotemTimers.AvailableTalents.LavaSurge = true end
    --if select(5, GetTalentInfo(1,13))>0 then TotemTimers.AvailableTalents.Fulmination = true end
end

local stripRank = TotemTimers.StripRank
local WindfurySpellID = SpellIDs.Windfury

local function UpdateSpellNameRank(spell)
    local rankedSpellID = tonumber(spell)
    if not rankedSpellID then
        local spellNameWithoutRank = stripRank(spell)
        rankedSpellID = NameToSpellID[spellNameWithoutRank]
    end
    local spellID = RankToSpellID[rankedSpellID]
    local maxSpellID = SpellIDsMaxRank[spellID]
    return maxSpellID or rankedSpellID
    --[[local spellID = NameToSpellID[spellNameWithoutRank]
    if spellID then
        if spellID == WindfurySpellID and TotemTimers.ActiveProfile.WindfuryDownrank then
            return TotemTimers.WindfuryRank1
        end
        local newRankName = SpellNames[spellID]
        if newRankName then return newRankName end
    end]]
    --return nil
end
TotemTimers.UpdateSpellNameRank = UpdateSpellNameRank

local function UpdateRank(button)
    for i = 1,3 do
        for _,type in pairs({"*spell", "spell", "doublespell"}) do
            local spell = button:GetAttribute(type..i)
                if spell then
                local newRankName = UpdateSpellNameRank(spell)
                if newRankName then
                    button:SetAttribute(type..i, newRankName)
                end
            end
        end
    end
end

function TotemTimers.UpdateSpellRanks()
    for _,timer in pairs(XiTimers.timers) do
        UpdateRank(timer.button)
        if timer.actionBar then
            for _,actionButton in pairs(timer.actionBar.buttons) do
                UpdateRank(actionButton)
            end
        end
    end
end

function TotemTimers.ChangedTalents()
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
