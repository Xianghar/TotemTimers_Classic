if select(2,UnitClass("player")) ~= "SHAMAN" then return end

if not LibStub then return end
local msq = LibStub("Masque", true)

function TotemTimers.InitMasque()
	if msq then
		local group = msq:Group("TotemTimers")
		for _,v in pairs(XiTimers.timers) do
            group:AddButton(v.button)
            group:AddButton(v.animation.button)
        end
        for i = 1,#TTActionBars.bars do
            for j = 1,#TTActionBars.bars[i].buttons do
                group:AddButton(TTActionBars.bars[i].buttons[j])
            end
        end
	end
end