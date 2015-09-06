--Taunt automatically three times a minute on average when a prop
local frequency = 3
local time = 60/(frequency * 2)
timer.Create( "autotaunt", time, 0, function()
	if LocalPlayer():Team() == 3 then
		if math.random(1,2) == 1 then
			RunConsoleCommand("ph_taunt_random") 
		end
	end
end )
