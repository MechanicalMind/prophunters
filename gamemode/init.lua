AddCSLuaFile("shared.lua")

local rootFolder = (GM or GAMEMODE).Folder:sub(11) .. "/gamemode/"

// add cs lua all the cl_ or sh_ files
local files, dirs = file.Find(rootFolder .. "*", "LUA")
for k, v in pairs(files) do
	if v:sub(1,3) == "cl_" || v:sub(1,3) == "sh_" then
		AddCSLuaFile(rootFolder .. v)
	end
end


include("shared.lua")
include("sh_class.lua")
include("sh_condef.lua")
include("sv_ragdoll.lua")
include("sv_chattext.lua")
include("sv_playercolor.lua")
include("sv_player.lua")
include("sv_realism.lua")
include("sv_rounds.lua")
include("sv_spectate.lua")
include("sv_respawn.lua")
include("sv_health.lua")
include("sh_weightedrandom.lua")
include("sv_killfeed.lua")
include("sv_statistics.lua")
include("sv_bot.lua")
include("sv_disguise.lua")
include("sv_teams.lua")
include("sv_taunt.lua")


util.AddNetworkString("clientIPE")
util.AddNetworkString("mb_openhelpmenu")
util.AddNetworkString("player_model_sex")

resource.AddFile("resource/fonts/Roboto-Black.ttf")
resource.AddFile("materials/melonbomber/skull.png")
resource.AddFile("materials/melonbomber/skull_license.txt")

function GM:Initialize() 
	self.DeathRagdolls = {}
	self:SetupStatisticsTables()
end

function GM:InitPostEntity() 
	self:InitPostEntityAndMapCleanup()

	RunConsoleCommand("mp_show_voice_icons", "0")
end

function GM:InitPostEntityAndMapCleanup() 
	for k, ent in pairs(ents.GetAll()) do
		if ent:GetClass():find("door") then
			ent:Fire("unlock","",0)
		end
	end
end

function GM:Think()
	self:RoundsThink()
	self:SpectateThink()
end

function GM:ShutDown()
end

function GM:AllowPlayerPickup( ply, ent )
	return true
end

function GM:PlayerNoClip( ply )
	timer.Simple(0, function () ply:CalculateSpeed() end)
	return ply:IsSuperAdmin() || ply:GetMoveType() == MOVETYPE_NOCLIP
end

function GM:OnEndRound()

end

function GM:OnStartRound()
	
end

function GM:EntityTakeDamage( ent, dmginfo )
	ent.LastDamageInfo = dmginfo
	if IsValid(ent) then
		if ent:IsPlayer() then
			if IsValid(dmginfo:GetAttacker()) then
				local attacker = dmginfo:GetAttacker()
				if attacker:IsPlayer() then
					if attacker:Team() == ent:Team() then
						return true
					end
				end
			end
		end
		if ent:IsDisguisableAs() then
			local att = dmginfo:GetAttacker()
			if IsValid(att) && att:IsPlayer() then
				local tdmg = DamageInfo()
				tdmg:SetDamage(math.min(dmginfo:GetDamage(), 3))
				att:TakeDamageInfo(tdmg)

				// increase stat for end of round (Angriest Hunter)
				att.PropDmgPenalty = (att.PropDmgPenalty or 0) + tdmg:GetDamage()
			end
		end
	end
end

function file.ReadDataAndContent(path)
	local f = file.Read(path, "DATA")
	if f then return f end
	f = file.Read(GAMEMODE.Folder .. "/content/data/" .. path, "GAME")
	return f
end

function GM:OnReloaded()
end

function GM:CleanupMap()
	game.CleanUpMap()
	hook.Call("InitPostEntityAndMapCleanup", self)
	hook.Call("MapCleanup", self)
end

function GM:ShowHelp(ply)
	net.Start("mb_openhelpmenu")
	net.Send(ply)
end

function GM:ShowSpare1(ply)
	net.Start("open_taunt_menu")
	net.Send(ply)
end

concommand.Add("ph_version", function (ply)
	if IsValid(ply) then
		local t = MsgClients()
		t:Add("Prophunters by Mechanical Mind version " .. tostring(GAMEMODE.Version or "error") .. "\n")
		t:Send(ply)
	else
		print("Prophunters by Mechanical Mind version " .. tostring(GAMEMODE.Version or "error"))
	end
end)