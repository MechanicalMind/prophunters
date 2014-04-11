local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function GM:PlayerDisguise(ply)

	local tr = ply:GetEyeTraceNoCursor()
	if IsValid(tr.Entity) then
		if tr.HitPos:Distance(tr.StartPos) < 75 then
			ply:DisguiseAsProp(tr.Entity)
		else
			-- ply:ChatPrint("too far " .. math.floor(tr.HitPos:Distance(tr.StartPos)))
		end
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

function PlayerMeta:DisguiseAsProp(ent)
	local hullxy = math.Round(math.Max(ent:OBBMaxs().x, ent:OBBMaxs().y, -ent:OBBMins().x, -ent:OBBMins().y))
	local hullz = math.Round(ent:OBBMaxs().z - ent:OBBMins().z)

	local can, why = self:CanDisguiseAsProp(ent)
	if !can then
		if why == 1 then
			local ct = ChatText()
			ct:Add("Not enough room to disguise as that, move further away", Color(255, 50, 50))
			ct:Send(self)
		end
		return
	end
	
	self:SetNWBool("disguised", true)
	self:SetNWString("disguiseModel", ent:GetModel())
	self:SetNWVector("disguiseMins", ent:OBBMins())
	self:SetNWVector("disguiseMaxs", ent:OBBMaxs())
	self:SetNoDraw(true)
	GAMEMODE:PlayerSetNewHull(self, hullxy, hullz, hullz)
end

function PlayerMeta:IsDisguised()
	return self:GetNWBool("disguised", false)
end

function PlayerMeta:UnDisguise()
	self:SetNWBool("disguised", false)
	self:SetNoDraw(false)
end