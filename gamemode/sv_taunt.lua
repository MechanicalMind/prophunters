include("sh_taunt.lua")

util.AddNetworkString("open_taunt_menu")

concommand.Add("ph_taunt", function (ply, com, args)
	if !IsValid(ply) then
		return
	end

	if !ply:Alive() then return end
	if ply:Team() != 3 then return end

	if ply.Taunting && ply.Taunting > CurTime() then
		return
	end

	local snd = args[1] or ""
	if !AllowedTauntSounds[snd] then
		return
	end

	local t = AllowedTauntSounds[snd]
	if t.sex && t.sex != ply.ModelSex then
		return
	end

	ply:EmitSound(snd)
	ply.Taunting = CurTime() + SoundDuration(snd) + 0.1
end)