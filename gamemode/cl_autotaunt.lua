--Taunt automatically every so often average once per so many seconds when a prop (number of seconds defined in the config) .
local minTime = 10 -- // TODO Get time from config.
local maxTime = 40 -- // TODO Get time from config.
local time = math.random(minTime,maxTime)
timer.Create( "autotaunt", 1, 0, function()
	if LocalPlayer():Team() == 3 then
		-- // TODO Check if player is taunting, if so reset the countdown.
		RunConsoleCommand("ph_taunt_random") 
		time = math.random(minTime,maxTime)
	end
end )
