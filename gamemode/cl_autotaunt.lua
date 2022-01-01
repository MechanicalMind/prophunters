
local autoTauntEnabled = CreateClientConVar("ph_autotaunt_enabled", 1)
local minTime = CreateClientConVar("ph_autotaunt_min", 30)
local maxTime = CreateClientConVar("ph_autotaunt_max", 60)
local time = math.random(minTime:GetInt(), maxTime:GetInt())
local timeElapsed = 0

timer.Create( "autotaunt", 0.5, 0, function()
	if IsValid(LocalPlayer()) && LocalPlayer():Team() == 3 && autoTauntEnabled:GetBool() then
		if timeElapsed > time then
			RunConsoleCommand("ph_taunt_random", "short")
			time = math.random(minTime:GetInt(), maxTime:GetInt())
			timeElapsed = 0
		end
		timeElapsed = timeElapsed + 0.5
	end
end )

function autoTauntReset(duration)
	local durationNum = tonumber(duration:ReadString());
	timeElapsed = -durationNum
end

usermessage.Hook("autoTauntReset", autoTauntReset );