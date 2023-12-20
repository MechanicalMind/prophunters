include("sh_disguise.lua")

local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function GM:PlayerDisguise(ply)

	if ply:Team() == 3 then
		local tr = ply:GetPropEyeTrace()
		if IsValid(tr.Entity) then
			if tr.HitPos:Distance(tr.StartPos) < 100 then
				if ply:CanDisguiseAsProp(tr.Entity) then
					if ply.LastDisguise && ply.LastDisguise + 1 > CurTime() then
						return
					end
					ply:DisguiseAsProp(tr.Entity)
				end
			else
				-- ply:ChatPrint("too far " .. math.floor(tr.HitPos:Distance(tr.StartPos)))
			end
		end
	end
end

function PlayerMeta:DisguiseAsProp(ent)

	local hullxy, hullz = ent:GetPropSize()
	if !self:CanFitHull(hullxy, hullxy, hullz) then
		local ct = ChatText()
		ct:Add("Not enough room to change", Color(255, 50, 50))
		ct:Send(self)
		return
	end
	
	if !self:IsDisguised() then
		self.OldPlayerModel = self:GetModel()
	end
	self:Flashlight(false)


	// create an entity for the disguise
	// we can't use a clientside entity as it needs a shadow
	local dent = self:GetNWEntity("disguiseEntity")
	if !IsValid(dent) then
		dent = ents.Create("ph_disguise")
		self:SetNWEntity("disguiseEntity", dent)
		dent.PropOwner = self
		dent:SetPos(self:GetPos())
		-- dent:SetParent(self)
		dent:Spawn()
	end
	dent:SetModel(ent:GetModel())
	
	self:SetNWBool("disguised", true)
	self:SetNWString("disguiseModel", ent:GetModel())
	self:SetNWVector("disguiseMins", ent:OBBMins())
	self:SetNWVector("disguiseMaxs", ent:OBBMaxs())
	self:SetNWInt("disguiseSkin", ent:GetSkin())
	self:SetNWBool("disguiseRotationLock", false)
	self:SetColor(Color(255, 0, 0, 0))
	self:SetRenderMode(RENDERMODE_NONE)
	self:SetModel(ent:GetModel())
	self:SetNoDraw(false)
	self:DrawShadow(false)
	GAMEMODE:PlayerSetNewHull(self, hullxy, hullz, hullz)


	local maxHealth = 1
	local volume = 1
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		maxHealth = math.Clamp(math.Round(phys:GetVolume() / 230), 1, 200)
		volume = phys:GetVolume()
	end
	self.PercentageHealth = math.min(self:Health() / self:GetHMaxHealth(), self.PercentageHealth or 1)
	local per = math.Clamp(self.PercentageHealth * maxHealth, 1, 200)
	self:SetHealth(per)
	self:SetHMaxHealth(maxHealth)
	self:SetNWFloat("disguiseVolume", volume)

	self:CalculateSpeed()


	local offset = Vector(0, 0, ent:OBBMaxs().z - self:OBBMins().z + 10)
	self:SetViewOffset(offset)
	self:SetViewOffsetDucked(offset)

	self:EmitSound("weapons/bugbait/bugbait_squeeze" .. math.random(1, 3) .. ".wav")
	self.LastDisguise = CurTime()

	local eff = EffectData()
	eff:SetOrigin(self:GetPos() + Vector(0, 0, 1))
	eff:SetScale(hullxy)
	eff:SetMagnitude(hullz)
	util.Effect("ph_disguise", eff, true, true)
end

function PlayerMeta:IsDisguised()
	return self:GetNWBool("disguised", false)
end

function PlayerMeta:UnDisguise()
	local dent = self:GetNWEntity("disguiseEntity")
	if IsValid(dent) then
		dent:Remove()
	end
	self.PercentageHealth = nil
	self:SetNWBool("disguised", false)
	self:SetColor(Color(255, 255, 255, 255))
	self:SetNoDraw(false)
	self:DrawShadow(true)
	self:SetRenderMode(RENDERMODE_NORMAL)
	GAMEMODE:PlayerSetNewHull(self)
	if self.OldPlayerModel then
		self:SetModel(self.OldPlayerModel)
		self.OldPlayerModel = nil
	end
	self:SetViewOffset(Vector(0, 0, 64))
	self:SetViewOffsetDucked(Vector(0, 0, 28))
	
	self:CalculateSpeed()
end

function PlayerMeta:DisguiseLockRotation()
	if !self:IsDisguised() then return end

	local mins, maxs = self:CalculateRotatedDisguiseMinsMaxs()
	local hullx = math.Round((maxs.x - mins.x) / 2)
	local hully = math.Round((maxs.y - mins.y) / 2)
	local hullz = math.Round(maxs.z - mins.z)
	if !self:CanFitHull(hullx, hully, hullz) then
		local ct = ChatText()
		ct:Add("Not enough room to lock rotation, move into a more open area", Color(255, 50, 50))
		ct:Send(self)
		return
	end

	local ang = self:EyeAngles()
	self:SetNWBool("disguiseRotationLock", true)
	self:SetNWFloat("disguiseRotationLockYaw", ang.y)
	GAMEMODE:PlayerSetHull(self, hullx, hully, hullz, hullz)
end

function PlayerMeta:DisguiseUnlockRotation()
	local maxs = self:GetNWVector("disguiseMaxs")
	local mins = self:GetNWVector("disguiseMins")
	local hullxy = math.Round(math.Max(maxs.x - mins.x, maxs.y - mins.y) / 2)
	local hullz = math.Round(maxs.z - mins.z)
	if !self:CanFitHull(hullxy, hullxy, hullz) then
		local ct = ChatText()
		ct:Add("Not enough room to unlock rotation, move into a more open area", Color(255, 50, 50))
		ct:Send(self)
		return
	end

	self:SetNWBool("disguiseRotationLock", false)
	GAMEMODE:PlayerSetHull(self, hullxy, hullxy, hullz, hullz)
end

concommand.Add("ph_lockrotation", function (ply, com, args)
	if !IsValid(ply) then return end
	if !ply:IsDisguised() then return end
	if ply:DisguiseRotationLocked() then
		ply:DisguiseUnlockRotation()
	else
		ply:DisguiseLockRotation()
	end
end)