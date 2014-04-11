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
					ply.PropMod = ClientsideModel(model)
					ply.PropMod:SetNoDraw(true)
					ply.PropMod:DrawShadow(true)
				end

				if IsValid(ply.PropMod) then
					local mins = ply:GetNWVector("disguiseMins")
					ply.PropMod:SetPos(ply:GetPos() + Vector(0, 0, -mins.z))
					local ang = ply:EyeAngles()
					ang.p = 0
					ply.PropMod:SetAngles(ang)
					ply.PropMod:DrawModel()
				end
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

function PlayerMeta:CanDisguiseAsProp(ent)
	local hullxy = math.Round(math.Max(ent:OBBMaxs().x, ent:OBBMaxs().y, -ent:OBBMins().x, -ent:OBBMins().y))
	local hullz = math.Round(ent:OBBMaxs().z - ent:OBBMins().z)
	
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos()
	trace.filter = self
	trace.maxs = Vector(hullxy, hullxy, hullz)
	trace.mins = Vector(-hullxy, -hullxy, 0)
	local tr = util.TraceHull(trace)
	if tr.Hit then 
		return false, 1
	end
	return true, 0
end


function GM:RenderDisguiseHalo()
	local client = LocalPlayer()
	if client:Team() == 3 then
		local tr = client:GetEyeTraceNoCursor()
		if IsValid(tr.Entity) then
			if tr.HitPos:Distance(tr.StartPos) < 75 then
				local col = Color(50, 150, 220)
				if !client:CanDisguiseAsProp(tr.Entity) then
					col = Color(150, 50, 50)
				end
				halo.Add({tr.Entity}, col, 2, 2, 5, true, false)
			end
		end
	end
end