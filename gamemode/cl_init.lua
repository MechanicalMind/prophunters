include("shared.lua")
include("sh_condef.lua")
include("cl_fixplayercolor.lua")
include("cl_ragdoll.lua")
include("cl_chattext.lua")
include("cl_rounds.lua")
include("cl_hud.lua")
include("cl_player.lua")
include("cl_scoreboard.lua")
include("cl_spectate.lua")
include("cl_health.lua")
include("sh_weightedrandom.lua")
include("cl_killfeed.lua")
include("cl_voicepanels.lua")
include("cl_helpscreen.lua")
include("cl_disguise.lua")

function GM:Initialize() 
end

function GM:InitPostEntity()
	net.Start("clientIPE")
	net.SendToServer()
end

function GM:Think()
end


function GM:EntityRemoved(ent)

end

function GM:PostDrawViewModel( vm, ply, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end

	end

end

function GM:RenderScene( origin, angles, fov )
	local client = LocalPlayer()
	if IsValid(client) then
		local wep = client:GetActiveWeapon()
		if IsValid(wep) && wep.PostDrawTranslucentRenderables then
			local errored, retval = pcall(wep.PostDrawTranslucentRenderables, wep)
			if !errored then
				print( retval )
			end
		end
	end
end


function GM:PostDrawTranslucentRenderables()

end
function GM:DrawMonitors()
end

function GM:PreDrawTranslucentRenderables()

end

function GM:PreDrawHalos()
	self:RenderDisguiseHalo()
end


function GM:OnReloaded()
end


function GM:CalcView(ply, pos, angles, fov)
	if self:IsCSpectating() && IsValid(self:GetCSpectatee()) then
		ply = self:GetCSpectatee()
	end
	if ply:IsPlayer() && !ply:Alive() then
		ply = ply:GetRagdollEntity()
	end
	if IsValid(ply) then
		if ply:IsPlayer() && ply:IsDisguised() then
			local maxs = ply:GetNWVector("disguiseMaxs")
			local mins = ply:GetNWVector("disguiseMins")
			local view = {}
			-- view.origin = pos + angles:Forward() * -(maxs.z - mins.z)
			-- local trace = {}
			-- trace.start = ply:GetPos()
			-- trace.endpos = ply:GetPropEyePos()
			view.origin = ply:GetPropEyePos() + angles:Forward() * -(maxs.z - mins.z)
			view.angles = angles
			view.fov = fov
			return view
		end
	end
end

function GM:ShouldDrawLocalPlayer()
	return false
end

function GM:CreateMove( cmd )

end

net.Receive("hull_set", function (len)
	local ply = net.ReadEntity()
	if !IsValid(ply) then return end
	local hullx = net.ReadFloat()
	local hully = net.ReadFloat()
	local hullz = net.ReadFloat()
	local duckz = net.ReadFloat()
	GAMEMODE:PlayerSetHull(ply, hullx, hully, hullz, duckz)
end)


function GM:RenderScene()
end

function GM:PostDrawEffects()
	self:RenderDisguises()
end

function GM:EntityRemoved(ent)
	if IsValid(ent.PropMod) then
		ent.PropMod:Remove()
	end
end

concommand.Add("+menu_context", function ()
	RunConsoleCommand("ph_lockrotation")
end)

concommand.Add("-menu_context", function ()
end)