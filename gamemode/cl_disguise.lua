include("sh_disguise.lua")

local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:IsDisguised()
	return self:GetNWBool("disguised", false)
end

local function renderDis(self)
	for k, ply in pairs(player.GetAll()) do
		if ply:Alive() && ply:IsDisguised() then
			local model = ply:GetNWString("disguiseModel")
			if model && model != "" then
				if !IsValid(ply.PropMod) || ply.PropMod:GetModel() != model then
					if IsValid(ply.PropMod) then
						ply.PropMod:Remove()
					end
					ply.PropMod = ClientsideModel(model)
					-- ply.PropMod:SetNoDraw(true)
					ply.PropMod:DrawShadow(true)
				end

				if IsValid(ply.PropMod) then
					local mins = ply:GetNWVector("disguiseMins")
					local maxs = ply:GetNWVector("disguiseMaxs")
					local ang = ply:EyeAngles()
					ang.p = 0
					local pos = ply:GetPos() + Vector(0, 0, -mins.z)
					local center = (maxs + mins) / 2
					center.z = 0
					center:Rotate(ang)
					DebugInfo(ply:EntIndex() , tostring(center))
					ply.PropMod:SetPos(pos - center)
					ply.PropMod:SetAngles(ang)
					-- ply.PropMod:DrawModel()
				end
			end
		else
			if IsValid(ply.PropMod) then
				ply.PropMod:Remove()
			end
		end
	end
end

function GM:RenderDisguises()
	
	cam.Start3D( EyePos(), EyeAngles() )
	local b, err = pcall(renderDis, self)
	cam.End3D()
	if !b then
		MsgC(Color(255, 0, 0), err .. "\n")
	end
end

function GM:RenderDisguiseHalo()
	local client = LocalPlayer()
	if client:Team() == 3 then
		local tr = client:GetEyeTraceNoCursor()
		if IsValid(tr.Entity) then
			if tr.HitPos:Distance(tr.StartPos) < 75 then
				if client:CanDisguiseAsProp(tr.Entity) then
					local col = Color(50, 150, 220)
					local hullxy, hullz = tr.Entity:GetPropSize()
					if !client:CanFitHull(hullxy, hullz) then
						col = Color(150, 50, 50)
					end
					halo.Add({tr.Entity}, col, 2, 2, 5, true, false)
				end
			end
		end
		local tab = {}
		for k, ply in pairs(player.GetAll()) do
			if ply != client && ply:Team() == 3 && ply:IsDisguised() then
				if IsValid(ply.PropMod) then
					table.insert(tab, ply.PropMod)
				end
			end
		end
		halo.Add(tab, team.GetColor(3), 2, 2, 5, true, false)
	end

end