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
include("sv_mapvote.lua")
include("sv_bannedmodels.lua")
include("sv_version.lua")


util.AddNetworkString("clientIPE")
util.AddNetworkString("mb_openhelpmenu")
util.AddNetworkString("player_model_sex")

resource.AddFile("materials/melonbomber/skull.png")
resource.AddFile("materials/melonbomber/skull_license.txt")

GM.VoiceHearTeam = CreateConVar("ph_voice_hearotherteam", 0, bit.bor(FCVAR_NOTIFY), "Can we hear the voices of opposing teams" )
GM.VoiceHearDead = CreateConVar("ph_voice_heardead", 1, bit.bor(FCVAR_NOTIFY), "Can we hear the voices of dead players and spectators" )
GM.RoundLimit = CreateConVar("ph_roundlimit", 10, bit.bor(FCVAR_NOTIFY), "Number of rounds before mapvote" )
GM.StartWaitTime = CreateConVar("ph_mapstartwait", 30, bit.bor(FCVAR_NOTIFY), "Number of seconds to wait for players on map start before starting round" )
GM.HunterDamagePenalty = CreateConVar("ph_hunter_dmgpenalty", 3, bit.bor(FCVAR_NOTIFY), "Amount of damage a hunter should take for shooting an incorrect prop" )
GM.HunterGrenadeAmount = CreateConVar("ph_hunter_smggrenades", 1, bit.bor(FCVAR_NOTIFY), "Amount of SMG grenades hunters should spawn with" )
GM.DeadSpectateRoam = CreateConVar("ph_dead_canroam", 0, bit.bor(FCVAR_NOTIFY), "Can dead players use the roam spectate mode" )
GM.PropsWinStayProps = CreateConVar("ph_props_onwinstayprops", 0, bit.bor(FCVAR_NOTIFY), "If the props win, they stay on the props team" )
GM.PropsSmallSize = CreateConVar("ph_props_small_size", 200, bit.bor(FCVAR_NOTIFY), "Size that speed penalty for small size starts to apply (0 to disable)" )
GM.PropsJumpPower = CreateConVar("ph_props_jumppower", 1.2, bit.bor(FCVAR_NOTIFY), "Jump power bonus for when props are disguised" )
GM.PropsCamDistance = CreateConVar("ph_props_camdistance", 1, bit.bor(FCVAR_NOTIFY), "The camera distance multiplier for props when disguised")

function GM:Initialize()
	self.RoundWaitForPlayers = CurTime()

	self.DeathRagdolls = {}
	self:SetupStatisticsTables()
	self:LoadMapList()
	self:LoadBannedModels()
end

function GM:InitPostEntity() 
	self:CheckForNewVersion()
	self:InitPostEntityAndMapCleanup()

	RunConsoleCommand("mp_show_voice_icons", "0")
end

function GM:InitPostEntityAndMapCleanup() 
	self:RemoveBannedModelProps()
	for k, ent in pairs(ents.GetAll()) do
		if ent:GetClass():find("door") then
			ent:Fire("unlock","",0)
		end
		if ent:IsDisguisableAs() then
			-- ent:DrawShadow(false)
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
			if IsValid(att) && att:IsPlayer() && att:Team() == 2 then

				if bit.band(dmginfo:GetDamageType(), DMG_CRUSH) != DMG_CRUSH then					
					local tdmg = DamageInfo()
					tdmg:SetDamage(math.min(dmginfo:GetDamage(), math.max(self.HunterDamagePenalty:GetInt(), 1) ))
					tdmg:SetDamageType(DMG_AIRBOAT)

					-- tdmg:SetAttacker(ent)
					-- tdmg:SetInflictor(ent)

					tdmg:SetDamageForce(Vector(0, 0, 0))
					att:TakeDamageInfo(tdmg)

					// increase stat for end of round (Angriest Hunter)
					att.PropDmgPenalty = (att.PropDmgPenalty or 0) + tdmg:GetDamage()
				end
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
