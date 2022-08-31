-- Copyright © 2008 Xianghar  <xian@zron.de>
-- All Rights Reserved.
-- This code is not to be modified or distributed without written permission by the author.
-- Current permissions only include curse.com, wowui.worldofwar.net, wowinterface.com and their respective addon updaters

local mb  -- abrev for MulticastButton

local SpellNames = TotemTimers.SpellNames
local AvailableSpells = TotemTimers.AvailableSpells

local SpellIDs = TotemTimers.SpellIDs

function TotemTimers.CreateMultiCastButtons()
    mb = CreateFrame("Button", "TotemTimers_MultiSpell", UIParent, "ActionButtonTemplate, SecureActionButtonTemplate, SecureHandlerEnterLeaveTemplate, SecureHandlerAttributeTemplate")
    mb:SetWidth(36) mb:SetHeight(36) mb:SetScale(32/36)
    --mb:SetPoint("CENTER", TotemTimers_MultiSpellFrame, "CENTER")
    mb.bar = TTActionBars:new(3, mb, nil, TotemTimersFrame)
    mb.icon = _G["TotemTimers_MultiSpellIcon"]
    mb:Show()
    
    --for rActionButtonStyler
    mb.action = 0 
    mb.SetCheckedTexture = function() end
    if not IsAddOnLoaded("rActionButtonStyler") then
        mb:SetNormalTexture(nil)
    else
        ActionButton_Update(mb)
    end
    mb.icon:Show()

    
    mb:SetAttribute("*type*", "spell")
    
    mb.UpdateTexture = function(self)
        local spell = self:GetAttribute("*spell1")
        if spell then
            local _,_,texture = GetSpellInfo(spell)
            if texture then
                self.icon:SetTexture(texture)
            end
        end
        TotemTimers.ActiveProfile.LastMultiCastSpell = spell
    end
    
    mb.HideTooltip = function(self) GameTooltip:Hide() end

    mb:SetAttribute("_onattributechanged", [[ if name == "*spell1" then
                                                  self:CallMethod("UpdateTexture")
                                                  self:ChildUpdate("mspell", value)
                                              elseif name == "state-invehicle" then
                                                 if value == "show" and self:GetAttribute("active") then
                                                    self:Show()
                                                    local s = self:GetAttribute("*spell1")
                                                    if s then self:SetAttribute("*spell1", s) end
                                                else
                                                    self:Hide()
                                                end
                                             end]])
    mb:WrapScript(mb, "OnClick", [[ if button == "Button4" then
                                                          control:ChildUpdate("toggle")
                                                      end ]])

    mb:SetScript("OnDragStart", function() if not InCombatLockdown() and not TotemTimers.ActiveProfile.Lock then TotemTimersFrame:StartMoving() end end)
    mb:SetScript("OnDragStop", function() 
        TotemTimersFrame:StopMovingOrSizing()
        TotemTimers.SaveFramePositions()
        --TotemTimers.ProcessSetting("MultiSpellBarDirection")
    end)
    mb:SetAttribute("OpenMenu", "mouseover")
    mb:SetAttribute("*spell2", SpellIDs.TotemicCall)
    mb:SetAttribute("*spell1", TotemTimers.ActiveProfile.LastMultiCastSpell or SpellIDs.CallOfElements)
    mb:SetAttribute("*spell3", SpellIDs.TotemicCall)
   -- mb:RegisterForClicks("LeftButton, RightButton")
    mb:RegisterForDrag("LeftButton")
    mb:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Down")
end

table.insert(TotemTimers.Modules, TotemTimers.CreateMultiCastButtons)


function TotemTimers.MultiSpellActivate()
    if TotemTimers.ActiveProfile.MultiCast and AvailableSpells[SpellIDs.CallOfElements] then
        for i=1,4 do
            XiTimers.timers[i].button:SetParent(mb)
        end
        mb:Show()
        TotemTimers.SetMultiCastSpells()
        mb.active = true
        TotemTimers.OrderTimers()
		--trigger Childupdate("mspell")
		mb:SetAttribute("*spell1", mb:GetAttribute("*spell1"))
    else
        for i=1,4 do
            XiTimers.timers[i].button:SetParent(UIParent)
        end
        mb:Hide()
        mb.active = false
        TotemTimers.OrderTimers()
    end
end

function TotemTimers.SetMultiCastSpells()
    mb.bar:ResetSpells()
    if AvailableSpells[SpellIDs.CallOfElements] then
        mb.bar:AddSpell(SpellIDs.CallOfElements)
    end
    if AvailableSpells[SpellIDs.CallOfAncestors] then
        mb.bar:AddSpell(SpellIDs.CallOfAncestors)
    end
    if AvailableSpells[SpellIDs.CallOfSpirits] then
        mb.bar:AddSpell(SpellIDs.CallOfSpirits)
    end
end

table.insert(TotemTimers.SpellUpdaters, TotemTimers.SetMultiCastSpells)


