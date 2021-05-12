--Taunt automatically every so often average once per so many seconds when a prop (number of seconds defined in the config) .
local minTime = 30 -- // TODO Get time from config.
local maxTime = 60 -- // TODO Get time from config.
local time = math.random(minTime,maxTime)
local timeElapsed = 0
timer.Create( "autotaunt", 1, 0, function()
	if LocalPlayer():Team() == 3 then
		if LocalPlayer().Taunting then
			timeElapsed = 0
		else
			if timeElapsed > time then
				RunConsoleCommand("ph_taunt_random short") 
				time = math.random(minTime,maxTime)
			end
		end
		timeElapsed = timeElapsed + 1
	end
end )
