if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local L = LibStub("AceLocale-3.0"):GetLocale("TotemTimers_GUI", true)


TotemTimers.options.args.sets = {
    type = "group",
    name = "Sets",
    args = {},
}

local SpellNames = TotemTimers.SpellNames


local ACD = LibStub("AceConfigDialog-3.0")
local ACR =	LibStub("AceConfigRegistry-3.0")

local frame, categoryID = ACD:AddToBlizOptions("TotemTimers", "Sets", "TotemTimers", "sets")
TotemTimers.HookGUIFrame(frame, categoryID)

frame:HookScript("OnShow", function(self)
    TotemTimers.options.args.sets.args = {}

    local args = TotemTimers.options.args.sets.args

    if #TotemTimers.ActiveProfile.TotemSets == 0 then
        args.desc = {
            type="description",
            name="You did not create any totem sets yet."
        }
    else
        for i = 1, #TotemTimers.ActiveProfile.TotemSets do
            local set = TotemTimers.ActiveProfile.TotemSets[i]

            table.insert(args,  {
                type = "header",
                order = i * 10,
                name = not set.name and "Set "..i or set.name
            })

            local totems = {}
            for element = 1,4 do
                if set[element] then
                    totems[element] = TotemTimers.ElementColors[element]:WrapTextInColorCode(SpellNames[set[element]])
                end
            end

            table.insert(args, {
                type = "description",
                order = i * 10 + 1,
                name = table.concat(totems, ", "),
            })

            table.insert(args, {
                type = "input",
                name = L["Rename"],
                order = i * 10 + 2,
                set = function(self, value)
                    set.name = value

                    ACR:NotifyChange("TotemTimers")
                    InterfaceOptionsFrame_OpenToCategory(frame)
                end,
            })

            table.insert(args, {
                type = "execute",
                name = L["Delete"],
                order = i * 10 + 3,
                func = function()
                	local popup = StaticPopup_Show("TOTEMTIMERS_DELETESET", not set.name and i or set.name)
                	popup.data = i
                end,
            })
        end
    end

    ACR:NotifyChange("TotemTimers")

end)

local deleteOnAccept = StaticPopupDialogs["TOTEMTIMERS_DELETESET"].OnAccept
StaticPopupDialogs["TOTEMTIMERS_DELETESET"].OnAccept = function(self, nr)
    deleteOnAccept(self, nr)
    if frame:IsVisible() then
        ACR:NotifyChange("TotemTimers")
        InterfaceOptionsFrame_OpenToCategory(frame)
    end
end
