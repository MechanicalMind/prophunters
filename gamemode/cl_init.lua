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
include("sh_pickups.lua")
include("cl_upgrades.lua")
include("sh_weightedrandom.lua")
include("cl_killfeed.lua")
include("cl_voicepanels.lua")
include("cl_helpscreen.lua")

GM.FirstPerson = CreateClientConVar( "mb_firstperson", 0, true, true )

function GM:Initialize() 
end

function GM:InitPostEntity()
	net.Start("clientIPE")
	net.SendToServer()
	GAMEMODE:PlayerSetNewHull(LocalPlayer())
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
end


function GM:PostDrawTranslucentRenderables()
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

function GM:PreDrawHalos()
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
		if !self.FirstPerson:GetBool() || ply != LocalPlayer() then
			local trace = {}
			trace.start = ply:GetPos() + Vector(0, 0, 100)
			trace.endpos = trace.start + Vector(0, 0, 300)
			trace.filter = ply
			-- trace.mask = MASK_SHOT
			local tr = util.TraceLine(trace)

			local view = {}
			view.origin = tr.HitPos + Vector(0, 0, -5)
			view.angles = Angle(90,90,0)
			view.fov = fov
			return view
		end
	end
end

function GM:ShouldDrawLocalPlayer()
	if !self.FirstPerson:GetBool() then
		return true
	end
	return false
end

GM.Zones = {}

net.Receive("spawn_zones", function ()
	GAMEMODE.Zones = {}
	while true do
		local k = net.ReadUInt(16)
		if k == 0 then break end
		local mins = net.ReadVector()
		local maxs = net.ReadVector()
		local sqsize = net.ReadFloat()

		local tab = {}
		tab.key = k
		tab.mins = mins
		tab.maxs = maxs
		tab.sqsize = sqsize
		GAMEMODE.Zones[k] = tab
	end
end)

function GM:GetZonePosFromEnt(ent)
	for k, zone in pairs(GAMEMODE.Zones) do
		local mins, maxs = zone.mins, zone.maxs
		mins = mins + ent:OBBMins()
		maxs = maxs + ent:OBBMaxs()
		local pos = ent:GetPos()
		if pos.x > mins.x && pos.x < maxs.x then
			if pos.y > mins.y && pos.y < maxs.y then
				local center = (zone.mins + zone.maxs) / 2
				local t = pos - center
				return zone, math.Round(t.x / zone.sqsize), math.Round(t.y / zone.sqsize)
			end
		end
	end
end

local lastangles = Angle()
function GM:CreateMove( cmd )

	if LocalPlayer():Alive() then
		if cmd:KeyDown(IN_JUMP) then
			cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK))
		end
		if cmd:KeyDown(IN_DUCK) then
			cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK2))
		end
		cmd:RemoveKey(IN_JUMP)
		cmd:RemoveKey(IN_DUCK)
		cmd:SetUpMove(0)

		if !self.FirstPerson:GetBool() then
			cmd:ClearMovement()

			local rel
			local zone, x, y = GAMEMODE:GetZonePosFromEnt(LocalPlayer())
			if zone then
				local center = (zone.mins + zone.maxs) / 2
				local t = LocalPlayer():GetPos() - center
				rel = t - Vector(x * zone.sqsize, y * zone.sqsize, t.z)
				-- DebugInfo(0, tostring(rel))
				-- DebugInfo(1, tostring(x))
				-- DebugInfo(2, tostring(y))
			end

			local vec = Vector(0, 0, 0)
			if cmd:KeyDown(IN_FORWARD) then
				cmd:SetForwardMove(100000)
				vec.y = 1
			elseif cmd:KeyDown(IN_BACK) then
				cmd:SetForwardMove(100000)
				vec.y = -1
			end

			if cmd:KeyDown(IN_MOVELEFT) then
				cmd:SetForwardMove(100000)
				lastangles = Angle(0, 180, 0)
				vec.x = -1
			elseif cmd:KeyDown(IN_MOVERIGHT) then
				cmd:SetForwardMove(100000)
				lastangles = Angle(0, 0, 0)
				vec.x = 1
			end


			if vec:Length() > 0 then
				lastangles = vec:Angle()
			end
			cmd:SetViewAngles(lastangles)

		else
		
		end
	end
end

net.Receive("hull_set", function (len)
	for k, ply in pairs(player.GetAll()) do
		GAMEMODE:PlayerSetNewHull(ply)
	end
end)

net.Receive("pk_elecplosion", function (len)
	local eff = EffectData()
	eff:SetOrigin(net.ReadVector())
	eff:SetScale(net.ReadDouble())
	eff:SetMagnitude(net.ReadDouble())
	util.Effect("pk_elecplosion", eff, true, true)
end)
