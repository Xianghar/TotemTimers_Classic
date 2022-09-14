if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local _, TotemTimers = ...

local SpellIDs = TotemTimers.SpellIDs
local SpellTextures = TotemTimers.SpellTextures
local SpellNames = TotemTimers.SpellNames
local AvailableSpells = TotemTimers.AvailableSpells
local LongCooldownSpells = TotemTimers.LongCooldownSpells

local cds = {}
TotemTimers.LongCooldowns = cds


local function ConfigureTimer(timer, data)
	timer.spell = data.spell
	timer.buff = data.buff
	timer.totem = data.totem
	timer.element = data.element
	timer.customOnEvent = nil
	if data.customOnEvent then timer.customOnEvent = TotemTimers[data.customOnEvent] end
	timer.events[1] = "SPELL_UPDATE_COOLDOWN"
	timer.playerEvents = {}
	if timer.buff then timer.playerEvents[1] = "UNIT_AURA" end
	if timer.totem then table.insert(timer.events, "PLAYER_TOTEM_UPDATE") end
	timer.button:SetAttribute("*spell1", timer.spell)
	timer.button.icon:SetTexture(SpellTextures[timer.spell])
end


function TotemTimers.CreateLongCooldowns()

	for _, data in pairs(LongCooldownSpells) do
		local timer = XiTimers:new(1)
		table.insert(cds, timer)

		timer.button:SetScript("OnEvent", XiTimers.TimerEvent)
		timer.button:RegisterForClicks("LeftButtonDown")
		timer.button:SetAttribute("*type*", "spell")

		timer.alpha = 0.7

		timer.anchorframe = TotemTimers_LongCooldownsFrame

		ConfigureTimer(timer, data)

		timer.Activate = function(self)
			XiTimers.Activate(self)
			XiTimers.TimerEvent(timer.button, "SPELL_UPDATE_COOLDOWN")
			XiTimers.TimerEvent(timer.button, "UNIT_AURA")
			XiTimers.TimerEvent(timer.button, "PLAYER_TOTEM_UPDATE", timer.element)
		end
	end
end

table.insert(TotemTimers.Modules, TotemTimers.CreateLongCooldowns)


function TotemTimers.ActivateLongCooldowns(activate)
	if activate then
		for _, timer in pairs(cds) do
			if AvailableSpells[timer.spell]
					and (TotemTimers.ActiveProfile.LongCooldownSpells[timer.spell]
					or TotemTimers.ActiveProfile.LongCooldownSpells[timer.spell] == nil)
			then timer:Activate() end
		end
		TotemTimers.LayoutLongCooldowns()
	else
		for _, timer in pairs(cds) do
			timer:Deactivate()
		end
	end
end

function TotemTimers.LayoutLongCooldowns()
	local point1, point2
	if TotemTimers.ActiveProfile.LongCooldownsArrange ~= "vertical" then
		point1 = "LEFT"
		point2 = "RIGHT"
	else
		point1 = "TOP"
		point2 = "BOTTOM"
	end

	local lastTimer = nil
	local first = true

	for _, timer in pairs(cds) do
		timer:ClearAnchors()
		if timer.active then
			if first then
				timer:SetPoint("CENTER", TotemTimers_LongCooldownsFrame, "CENTER")
				first = false
			else
				timer:Anchor(lastTimer, point1, point2)
			end
			lastTimer = timer
		end
	end
end

function TotemTimers.FeralSpiritEvent() end

function TotemTimers.CDTotemEvent() end


