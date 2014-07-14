include("sh_taunt.lua")

util.AddNetworkString("open_taunt_menu")

concommand.Add("ph_taunt", function (ply, com, args, full)
	if !IsValid(ply) then
		return
	end

	if !ply:Alive() then return end

	if ply.Taunting && ply.Taunting > CurTime() then
		return
	end

	local snd = args[1] or ""
	if !AllowedTauntSounds[snd] then
		return
	end

	local t
	for k, v in pairs(AllowedTauntSounds[snd]) do
		if v.sex && v.sex != ply.ModelSex then
			continue
		end

		if v.team && v.team != ply:Team() then
			continue
		end

		t = v
	end

	if !t then
		return
	end

	local duration = SoundDuration(snd)
	if snd:match("%.mp3$") then
		duration = t.soundDurationOverride or 1
	end

	ply:EmitSound(snd)
	ply.Taunting = CurTime() + duration + 0.1
	ply.TauntAmount = (ply.TauntAmount or 0) + 1
end)

concommand.Add("ph_taunt_random", function (ply, com, args, full)
	if !IsValid(ply) then
		return
	end

	if !ply:Alive() then return end

	if ply.Taunting && ply.Taunting > CurTime() then
		return
	end

	local potential = {}
	for k, v in pairs(Taunts) do
		if v.sex && v.sex != ply.ModelSex then
			continue
		end

		if v.team && v.team != ply:Team() then
			continue
		end

		table.insert(potential, v)
	end

	if #potential == 0 then 
		return
	end

	local t = potential[math.random(#potential)]
	local snd = t.sound[math.random(#t.sound)]

	local duration = SoundDuration(snd)
	if snd:match("%.mp3$") then
		duration = t.soundDurationOverride or 1
	end

	ply:EmitSound(snd)
	ply.Taunting = CurTime() + duration + 0.1
	ply.TauntAmount = (ply.TauntAmount or 0) + 1
end)