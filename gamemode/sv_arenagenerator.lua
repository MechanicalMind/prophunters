
ClassGenerator = class()
local Gen = ClassGenerator

function Gen:initialize(grid, mins, maxs)
	self.containers = {}
	self.walls = {}
	self.crates = {}
	self.grid = grid
	self.mins = mins
	self.maxs = maxs
	self.center = (maxs + mins) / 2
end

function Gen:spawnProp(pos, ang, mdl, opts)
	local ent = ents.Create("prop_physics")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetModel(mdl)
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		if !opts || !opts.nofreeze then
			phys:EnableMotion(false)
		end
	end
	if !opts || !opts.nomotion then
		-- ent:SetMoveType(MOVETYPE_NONE)
	end
	local skins = ent:SkinCount()
	ent:SetSkin(math.random(skins))
	return ent
end

// 0 is neg y
// 1 is pos x
// 2 is pos y
// 3 is neg x

function Gen:createBox(x, y, strength)
	local angles = Angle(0, 0, 0)

	local size = 20
	local add = self.center + Vector(self.grid.sqsize, 0, 0) * x  + Vector(0, self.grid.sqsize, 0) * y
	local pos = add * 1
	pos.z = self.mins.z

	local ent = self:spawnProp(pos, angles, "models/hunter/blocks/cube075x075x075.mdl")
	if strength && strength > 1 then
		ent:SetMaterial("models/props_c17/metalladder002")
	else
		ent:SetMaterial("models/props/CS_militia/roofbeams03")
		local b = math.random(200, 255)
		ent:SetColor(Color(255, b, b))
	end
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
	end
	local skins = ent:SkinCount()
	ent:SetSkin(math.random(skins))

	pos.z = pos.z - ent:OBBMins().z + math.Rand(0, 0.05) - 4
	ent:SetPos(pos)

	ent.gridX = x
	ent.gridY = y
	ent.gridType = "box"
	ent.gridWalkable = true
	ent.gridBreakable = true
	ent.gridSolid = true
	ent.gridStrength = strength or 1
	ent.gridMaxStrength = strength or 1
	table.insert(self.crates, ent)

	self.grid:setSquare(x, y, ent)
	return ent
end

function Gen:createWall(x, y, t)
	local angles = Angle(0, 0, 90)

	local size = 20
	local add = self.center + Vector(self.grid.sqsize, 0, 0) * x  + Vector(0, self.grid.sqsize, 0) * y
	local pos = add * 1
	pos.z = self.mins.z

	local ent = self:spawnProp(pos, angles, "models/hunter/blocks/cube075x075x075.mdl")
	if t == 2 then
		ent:SetMaterial("models/props_c17/metalladder003")
	else
		ent:SetMaterial("models/props_canal/metalwall005b")
	end
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
	end
	local skins = ent:SkinCount()
	ent:SetSkin(math.random(skins))

	pos.z = pos.z - ent:OBBMins().z + math.Rand(-0.1, 0.1)
	ent:SetPos(pos)

	ent.gridX = x
	ent.gridY = y
	ent.gridType = "wall"
	ent.gridWalkable = false
	ent.gridSolid = true
	table.insert(self.walls, ent)

	self.grid:setSquare(x, y, ent)
	return ent
end

function Gen:generate()

	// generate map
	for i = 0, (self.grid:getWidth()) * (self.grid:getHeight()) - 1 do
		local x = i % (self.grid:getWidth()) - self.grid.sizeLeft
		local y = math.floor(i / (self.grid:getWidth())) - self.grid.sizeUp
		if x % 2 == 0 && y % 2 == 0 then
			self:createWall(x, y)
		else
			if math.random(4) != 1 then
				if math.random(1, 15) == 1 then
					self:createBox(x, y, 3)
				else
					self:createBox(x, y)
				end
			end
		end
	end

	// generate walls around map
	for i = -self.grid.sizeLeft - 1, self.grid.sizeRight + 1 do 
		self:createWall(i, -self.grid.sizeUp - 1, 2)
		self:createWall(i, self.grid.sizeDown + 1, 2)
	end

	for i = -self.grid.sizeUp, self.grid.sizeDown do
		self:createWall(-self.grid.sizeLeft - 1, i, 2)
		self:createWall(self.grid.sizeRight + 1, i, 2)
	end

end

// capture point
// models/props_combine/combinecrane002.mdl