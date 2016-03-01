include("shared.lua")
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
include("cl_taunt.lua")
include("cl_endroundboard.lua")
include("cl_wraptext.lua")
include("cl_mapvote.lua")
include("cl_bannedmodels.lua")

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



local function lerp(from, to, step)
	if from < to then
		return math.min(from + step, to)	
	end
	return math.max(from - step, to)
end

local camDis, camHeight = 0,0 
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

			local reach = (maxs.z - mins.z)
			if self:GetRoundSettings() && self:GetRoundSettings().PropsCamDistance then
				reach = reach * self:GetRoundSettings().PropsCamDistance
			end
			local trace = {}
			trace.start = ply:GetPropEyePos()
			trace.endpos = trace.start + angles:Forward() * -reach
			local tab = ents.FindByClass("prop_ragdoll")
			table.insert(tab, ply)
			trace.filter = tab

			local a = 3
			trace.mins = Vector(math.max(-a, mins.x), math.max(-a, mins.y), math.max(-a, mins.z))
			trace.maxs = Vector(math.min(a, maxs.x), math.min(a, maxs.y), math.min(a, maxs.z))
			tr = util.TraceHull(trace)
			camDis = lerp(camDis, (tr.HitPos - trace.start):Length(), FrameTime() * 300)
			camHeight = lerp(camHeight, (ply:GetPropEyePos() - ply:GetPos()).z, FrameTime() * 300)
			local camPos = trace.start * 1
			camPos.z = ply:GetPos().z + camHeight
			view.origin = camPos + (trace.endpos - trace.start):GetNormal() * camDis
			-- view.origin = tr.HitPos

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
	self:RenderDisguises()
end

function GM:PostDrawEffects()
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

net.Receive("player_model_sex", function ()
	local sex = net.ReadString()
	if #sex == 0 then
		sex = nil
	end
	GAMEMODE.PlayerModelSex = sex
end)

function GM:StartChat()
	if IsValid(self.EndRoundPanel) && self.EndRoundPanel:IsVisible() then
		timer.Simple(0, function () chat.Close() end)

		self.EndRoundPanel:SetKeyboardInputEnabled(true)
		self.EndRoundPanel.ChatTextEntry:RequestFocus()
		return true
	end
end

function GM:ChatText(i, name, text, filter)
	self:EndRoundAddChatText(Color(0, 120, 220), text)

	if ( filter == "chat" ) then
		Msg( name, ": ", text, "\n" )
	else
		Msg( text, "\n" )
	end
	
	return false
end