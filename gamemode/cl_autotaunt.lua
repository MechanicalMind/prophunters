
local minTime = CreateClientConVar( "ph_autotaunt_min", 30)
local maxTime = CreateClientConVar( "ph_autotaunt_max", 60)
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
				timeElapsed = 0
			end
		end
		timeElapsed = timeElapsed + 1
	end
end )
