local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

local allowClasses = {"prop_physics", "prop_physics_multiplayer"}

function PlayerMeta:CanDisguiseAsProp(ent)
	if !self:Alive() then return false end
	if self:Team() != 3 then return false end
	if !IsValid(ent) then return false end

	if !table.HasValue(allowClasses, ent:GetClass()) then
		return false
	end

	return true
end

function PlayerMeta:CanFitHull(hullxy, hullz)
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos()
	trace.filter = self
	trace.maxs = Vector(hullxy, hullxy, hullz)
	trace.mins = Vector(-hullxy, -hullxy, 0)
	local tr = util.TraceHull(trace)
	if tr.Hit then 
		return false
	end
	return true
end


function EntityMeta:GetPropSize()
	local hullxy = math.Round(math.Max(self:OBBMaxs().x - self:OBBMins().x, self:OBBMaxs().y - self:OBBMins().y) / 2)
	local hullz = math.Round(self:OBBMaxs().z - self:OBBMins().z)
	return hullxy, hullz
end
