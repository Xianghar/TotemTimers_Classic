if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local _, TotemTimers = ...

local eventFrame = CreateFrame("Frame")

local isSOD = C_Seasons.GetActiveSeason() == 2

local SpellNames = TotemTimers.SpellNames

local Procs = {}
TotemTimers.Procs = Procs


local centerFrame = CreateFrame("Frame", "TotemTimers_CenterProcFrame", UIParent)
centerFrame:Hide()
centerFrame:SetSize(130,65)
centerFrame:SetFrameLevel(3)
local centerTexture = centerFrame:CreateTexture(nil, "BACKGROUND")
centerTexture:SetAllPoints(centerFrame)
centerFrame.pulseAnimation = XiTimersAnimations:new(centerFrame)
centerFrame.pulseAnimation.button:SetSize(72,36)

local leftFrame = CreateFrame("Frame", "TotemTimers_LeftProcFrame", UIParent)
leftFrame:Hide()
leftFrame:SetFrameLevel(100)
leftFrame:SetSize(65,130)
leftFrame:SetFrameLevel(3)
local leftTexture = leftFrame:CreateTexture(nil, "BACKGROUND")
leftTexture:SetAllPoints(leftFrame)
leftFrame.pulseAnimation = XiTimersAnimations:new(leftFrame)
leftFrame.pulseAnimation.button:SetSize(36,72)

local rightFrame = CreateFrame("Frame", "TotemTimers_RightProcFrame", UIParent)
rightFrame:Hide()
rightFrame:SetFrameLevel(100)
rightFrame:SetSize(65,130)
rightFrame:SetFrameLevel(3)
local rightTexture = rightFrame:CreateTexture(nil, "BACKGROUND")
rightTexture:SetAllPoints(rightFrame)
rightTexture:SetTexCoord(1,0,0,1)
rightFrame.pulseAnimation = XiTimersAnimations:new(rightFrame)
rightFrame.pulseAnimation.button:SetSize(36,72)
rightFrame.pulseAnimation.icon:SetTexCoord(1,0,0,1)

local centerProc = nil
local sideProc = nil

for _, icon in pairs({centerTexture, leftTexture, rightTexture}) do
    icon.AnimGroup = icon:CreateAnimationGroup()
    icon.AnimGroup:SetLooping("REPEAT")
    local scale = icon.AnimGroup:CreateAnimation("Scale")
    scale:SetDuration(0.4)
    scale:SetScale(1.05,1.05)
    scale:SetOrder(1)
    scale:SetSmoothing("IN_OUT")
    scale = icon.AnimGroup:CreateAnimation("Scale")
    scale:SetDuration(0.4)
    scale:SetScale(0.95,0.95)
    scale:SetOrder(2)
    scale:SetSmoothing("IN_OUT")
end

local function GetSpellFromAction(action)
    local spell = nil
    if action then
        local actionType, id = GetActionInfo(action)
        if actionType == "spell" then
            spell = id
        elseif actionType == "macro" then
            spell = GetMacroSpell(id)
        end
    end
    if spell then
        return TotemTimers.GetBaseSpellID(spell)
    end
end

function TotemTimers.CreateProcs()
    TotemTimers.LayoutProcs()
    eventFrame:SetScript("OnEvent", TotemTimers.ProcEvent)
    eventFrame:RegisterUnitEvent("UNIT_AURA", "player")
end

table.insert(TotemTimers.Modules, TotemTimers.CreateProcs)



function TotemTimers.LayoutProcs()
    centerFrame:SetAllPoints(TotemTimers.EnhanceCDsCenterProcAnchor)
    leftFrame:SetAllPoints(TotemTimers.EnhanceCDsLeftProcAnchor)
    rightFrame:SetAllPoints(TotemTimers.EnhanceCDsRightProcAnchor)
end


function TotemTimers.ToggleProcs(enable)
    if enable then
        eventFrame:Show()
    else
        eventFrame:Hide()
        centerFrame:Hide()
        leftFrame:Hide()
        rightFrame:Hide()
    end
end


function TotemTimers.ProcEvent(self, event, ...)
    for _, proc in pairs(Procs) do
        proc:Check()
    end
end


TotemTimersProcs = {}
TotemTimersProcs.__index = TotemTimersProcs

function TotemTimersProcs:new(isCenter, buff, textures, flashSpells, animateOn, glow)
    local self = {}
    setmetatable(self, TotemTimersProcs)

    self.isCenter = isCenter
    self.textures = textures
    self.buff = TotemTimers.SpellNames[buff]
    self.flashSpells = {}
    if flashSpells and type(flashSpells) == "table" then
        for _, spell in pairs(flashSpells) do
            self.flashSpells[spell] = true
        end
    end
    self.animateOn = animateOn or 1
    self.glow = glow
    self.buttons = {}

    return self
end

function TotemTimersProcs:Check()
    -- check for buff
    local _,_, count = AuraUtil.FindAuraByName(self.buff, "player", "HELPFUL")
    if count then
        self:Show(count)
    else
        self:Hide()
    end
end

function TotemTimersProcs:Show(count)
    local texture = self.textures[count] or self.textures[1]

    if self.isCenter then
        centerTexture:SetTexture(texture)
        centerFrame:Show()
        centerProc = self
        if count >= self.animateOn and (not self.lastCount or self.lastCount < count) then
            centerTexture.AnimGroup:Play()
            centerFrame.pulseAnimation.icon:SetTexture(texture)
            centerFrame.pulseAnimation:Play()
        elseif count < self.animateOn then
            centerTexture.AnimGroup:Stop()
        end
    else
        leftTexture:SetTexture(self.textures[1])
        leftFrame:Show()

        if self.animateOn == 1 or count >= self.animateOn then
            rightTexture:SetTexture(self.textures[1])
            rightFrame:Show()
        else
            rightFrame:Hide()
        end

        sideProc = self
        if count >= self.animateOn and (not self.lastCount or self.lastCount < count) then
            leftTexture.AnimGroup:Play()
            rightTexture.AnimGroup:Play()
            leftFrame.pulseAnimation.icon:SetTexture(texture)
            leftFrame.pulseAnimation:Play()
            rightFrame.pulseAnimation.icon:SetTexture(texture)
            rightFrame.pulseAnimation:Play()
        elseif count < self.animateOn then
            leftTexture.AnimGroup:Stop()
            rightTexture.AnimGroup:Stop()
        end
    end
    self:ToggleGlow(count)
    self.lastCount = count;
end

function TotemTimersProcs:Hide()
    if self.isCenter and centerProc == self then
        centerFrame:Hide()
        centerProc = nil
    elseif not self.isCenter and sideProc == self then
        leftFrame:Hide()
        rightFrame:Hide()
        sideProc = nil
    end
    self:ToggleGlow(0)
end

function TotemTimersProcs:CheckButton(button, spell)
    self.buttons[button] = (spell and self.flashSpells[spell]) or nil
end

function TotemTimersProcs:ToggleGlow(count)
    if not self.glow then return end
    if count >= self.glow then
        self.glowing = true
        for button in pairs(self.buttons) do
            ActionButton_ShowOverlayGlow(button)
        end
    elseif self.glowing then
        self.glowing = false
        for button in pairs(self.buttons) do
            ActionButton_HideOverlayGlow(button)
        end
    end
end

-- create procs and hook buttons

if TotemTimers.ProcData then
    for _, proc in pairs(TotemTimers.ProcData) do
        table.insert(Procs, TotemTimersProcs:new(proc.isCenter, proc.buff, proc.textures, proc.flashSpells, proc.animateOn, proc.glow))
    end
end


local function ActionButton_UpdateHook(self)
    local actionType, action
    if self.action and HasAction(self.action) then
        action = self.action
    else
        if self.HasAction and self.GetAction and self:HasAction() then
            actionType, action = self:GetAction()
        end
    end
    local spell = GetSpellFromAction(action)
    for _, proc in pairs(Procs) do
        proc:CheckButton(self, spell)
    end
    ActionButton_HideOverlayGlow(self)
end

hooksecurefunc("ActionButton_Update", ActionButton_UpdateHook)

local function XiTimersButtonUpdate()
    for t = 1, #TotemTimers.EnhanceCDs do
        for _, proc in pairs(Procs) do
            local button = TotemTimers.EnhanceCDs[t].button
            proc:CheckButton(button, button.cdspell)
        end
    end
end

hooksecurefunc(TotemTimers, "ConfigEnhanceCDs", XiTimersButtonUpdate)


eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    eventFrame:UnregisterEvent("PLAYER_LOGIN")
    local lab = LibStub("LibActionButton-1.0", true);
    local labelvui = LibStub("LibActionButton-1.0-ElvUI", true);

    local function buttonUpdate(event, button)
        ActionButton_UpdateHook(button)
    end

    if lab then
        lab:RegisterCallback("OnButtonUpdate", buttonUpdate)
    end
    if labelvui then
        labelvui:RegisterCallback("OnButtonUpdate", buttonUpdate)
    end
end)

