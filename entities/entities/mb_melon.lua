
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.PrintName		= "Melon"
ENT.Author			= "Mechanical Mind"
ENT.Information		= ""
ENT.Category		= "Melons"

ENT.Editable			= true
ENT.Spawnable			= true
ENT.AdminOnly			= false
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT


function ENT:SetupDataTables()

end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end


function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel("models/hunter/blocks/cube075x075x075.mdl")

		self:PhysicsInit( SOLID_VPHYSICS )
		local i = 40
		-- self:PhysicsInitBox(Vector(-40, -40, -40), Vector(40, 40, 40))
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			-- phys:SetDamping(0.3, 0.3)
			-- local int = 0.0011
			-- phys:SetInertia(Vector(int,int,int))
			-- phys:SetMass(50)
		end
		
		self:SetHealth(1)

		self:SetUseType( SIMPLE_USE )

		self:PrecacheGibs()

		self:DrawShadow(false)

		self.ShouldCollidePlayer = {}

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
		end
	else 
		self.MSize = 0
	end

	self.CreateTime = CurTime()
	self.ExplodeTime = CurTime() + 3
	
end

if ( CLIENT ) then

	function ENT:Draw()
		self.MSize = math.Approach(self.MSize, 1, FrameTime() * 10)

		if !IsValid(self.Melon) then
			self.Melon = ClientsideModel("models/props_junk/watermelon01.mdl")
			self.Melon:SetNoDraw(true)
			self.Melon:SetAngles(AngleRand())
		end
		if IsValid(self.Melon) then
			local left = math.min(1, (3 - (self.ExplodeTime - CurTime()) ) / 3)
			local size = left * 0.2 + 1.2 + math.sin((CurTime() - self.CreateTime) * 4) * 0.15
			if self:GetRemoteDetonate() then
				size = left * 0.2 + 1.2
			end
			if self:GetPowerBomb() then
				size = size * 1.2
			end
			size = size * self.MSize

			self.Melon:SetModelScale(size, 0)
			local pos = self:GetPos()

			-- if self:GetKicking() then
				if !self.MelonLastPos then self.MelonLastPos = self:GetPos() end
				self.MelonLastPos.x = math.Approach(self.MelonLastPos.x, self:GetPos().x, FrameTime() * 175)
				self.MelonLastPos.y = math.Approach(self.MelonLastPos.y, self:GetPos().y, FrameTime() * 175)
				self.MelonLastPos.z = math.Approach(self.MelonLastPos.z, self:GetPos().z, FrameTime() * 175)
				pos = self.MelonLastPos
			-- end

			self.Melon:SetPos(pos + Vector(0, 0, -18 + 10))
			if self:GetPowerBomb() then
				if !self.Melon.PowerBomb then
					self.Melon.PowerBomb = true
					self.Melon:SetMaterial("models/weapons/v_crowbar/crowbar_cyl")
				end
			end
			self.Melon:DrawModel()

			if self:GetPierce() then
				if !IsValid(self.SawBlade) then
					self.SawBlade = ClientsideModel("models/props_junk/sawblade001a.mdl")
					self.SawBlade:SetNoDraw(true)
					self.SawBlade:SetAngles(Angle(0, math.Rand(0, 360), 0))
				end
				if IsValid(self.SawBlade) then
					self.SawBlade:SetModelScale(size * 0.6, 0)
					self.SawBlade:SetPos(pos + Vector(0, 0, -18 + 10))
					local ang = self.SawBlade:GetAngles()
					ang:RotateAroundAxis(ang:Up(), FrameTime() * -400)
					self.SawBlade:SetAngles(ang)
					self.SawBlade:DrawModel()
				end
			end

			if self:GetRemoteDetonate() then
				if !IsValid(self.Antenna) then
					self.Antenna = ClientsideModel("models/props_rooftop/roof_dish001.mdl")
					self.Antenna:SetNoDraw(true)
					self.Antenna:SetAngles(Angle(0, math.Rand(0, 360), 0))
				end
				if IsValid(self.Antenna) then
					local ang = self.Antenna:GetAngles()
					ang:RotateAroundAxis(ang:Up(), FrameTime() * 13)
					self.Antenna:SetAngles(ang)
					self.Antenna:SetModelScale(size * 0.25, 0)
					self.Antenna:SetPos(pos + Vector(0, 0, -18 + 10))
					self.Antenna:DrawModel()
				end
			end
		end
	end

end

function ENT:OnRemove()
	if CLIENT then
		if IsValid(self.Melon) then
			self.Melon:Remove()
		end
	end
end

function ENT:PhysicsCollide( data, physobj )

	
end

function ENT:OnTakeDamage( dmginfo )
	-- self:TakePhysicsDamage( dmginfo )
	-- local nh = self:Health() - dmginfo:GetDamage()
	-- if nh <= 0 then
	-- 	self:GibBreakClient(dmginfo:GetDamageForce())
	-- 	self:Remove()
	-- end
end

function ENT:Think()
	if SERVER then
		for k, ply in pairs(player.GetAll()) do
			if ply:Alive() && !self:GetNWBool("MelonCollide" .. ply:EntIndex()) then
				local t = self:GetPos() - ply:GetPos()
				// 18 is half block
				// 35 is half player width
				// 1 is hacky fix
				local d = 18 + 10 + 1
				if math.abs(t.x) < d && math.abs(t.y) < d then

				else
					self:SetNWBool("MelonCollide" .. ply:EntIndex(), true)
				end
			end
		end

		if self:GetRemoteDetonate() && !self.HasRemoteAlarmed && self.CreateTime + 1 < CurTime() then
			self.HasRemoteAlarmed = true
			if IsValid(self:GetBombOwner()) then
				self:GetBombOwner():EmitSound("npc/roller/remote_yes.wav", 40, 70)
			end
		end

		if self.ExplodeTime < CurTime() && !self:GetRemoteDetonate() then
			self:Explode()
			return true
		end

		if self:GetKicking() then
			if self.KickingDelay && self.KickingDelay > CurTime() then

			else
				self.KickingDelay = CurTime() + 0.2
				local zone, x, y = GAMEMODE:GetGridPosFromEnt(self)
				if zone then

					local sx = x + math.Round(self.KickingDir.x)
					local sy = y + math.Round(self.KickingDir.y)
					if GAMEMODE:IsGridPosClear(zone, sx, sy) then
						self:SetPos(self:GetPos() + self.KickingDir * zone.grid.sqsize)
						local sq = zone.grid:getSquare(sx, sy)
						if IsValid(sq) then
							sq:Remove()
						end
						zone.grid:setSquare(sx, sy, self)
						zone.grid:setSquare(x, y, nil)
					else
						self:SetKicking(false)
						local ent = zone.grid:getSquare(sx, sy)
						if IsValid(ent) && ent:GetClass() == "mb_melon" then
							ent:KickMelon(self.KickingDir)
							sound.Play("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", self:GetPos(), 75, math.random( 90, 120 ))
						end
					end
				else
					self:SetKicking(false)
				end
			end
		end

		self:NextThink(CurTime() + 0.1)
		return true
	end
end

function ENT:KickMelon(dir)
	local zone, x, y = GAMEMODE:GetGridPosFromEnt(self)
	if zone then
		local sx = x + math.Round(dir.x)
		local sy = y + math.Round(dir.y)
		if GAMEMODE:IsGridPosClear(zone, sx, sy) then
			self:SetKicking(true)
			self.KickingDelay = CurTime() + 0
			self.KickingDir = dir
			return true
		end
	end
	return false
end

function ENT:StartTouch(ent)
	local phys = self:GetPhysicsObject()
	if ent:IsPlayer() && ent:HasUpgrade(8) then
		if IsValid(phys) then
			if !self:GetKicking() then
				// get the direction
				local ang = (self:GetPos() - ent:GetPos()):Angle()
				ang.p = 0
				ang.y = math.Round(ang.y / 90) * 90
				local dir = ang:Forward()

				if self:KickMelon(dir) then
					self:EmitSound("npc/fast_zombie/claw_strike3.wav")
				end
			end
		end
	end
end

function ENT:Explode(zone, combiner)
	if self.HasExploded then return end
	self.HasExploded = true
	-- self:GibBreakClient(Vector(0, 0, 4))
	if zone then
		local x, y = GAMEMODE:GetGridPosFromEntZone(zone, self)
		if x then
			GAMEMODE:CreateExplosion(zone, x, y, self:GetExplosionLength(), self, combiner)
		end
	else
		local zone, x, y = GAMEMODE:GetGridPosFromEnt(self)
		if zone then
			GAMEMODE:CreateExplosion(zone, x, y, self:GetExplosionLength(), self)
		end
	end
	self:Remove()
end

// big chunks
// models/props_junk/watermelon01_chunk01a.mdl
// models/props_junk/watermelon01_chunk01b.mdl
// models/props_junk/watermelon01_chunk01c.mdl

// little chunks
// models/props_junk/watermelon01_chunk02a.mdl
// models/props_junk/watermelon01_chunk02b.mdl
// models/props_junk/watermelon01_chunk02c.mdl

function ENT:Use( ply, caller )
end

function ENT:GetBombOwner()
	return self:GetNWEntity("BombOwner")
end

function ENT:SetBombOwner(ply)
	self:SetNWEntity("BombOwner", ply)
end

function ENT:SetPierce(bool)
	self:SetNWBool("BombPierce", bool)
end

function ENT:GetPierce()
	return self:GetNWBool("BombPierce")
end

function ENT:SetPowerBomb(bool)
	self:SetNWBool("BombPowerBomb", bool)
end

function ENT:GetPowerBomb()
	return self:GetNWBool("BombPowerBomb")
end

function ENT:SetRemoteDetonate(bool)
	self:SetNWBool("BombRemoteDetonate", bool)
end

function ENT:GetRemoteDetonate()
	return self:GetNWBool("BombRemoteDetonate")
end

function ENT:SetExplosionLength(len)
	self.ExplosionLength = len
end

function ENT:GetExplosionLength()
	if self:GetPowerBomb() then
		return 10
	end
	return self.ExplosionLength or 1
end

function ENT:SetKicking(bool)
	self.Kicking = bool
	self:SetNWBool("MelonKicking", bool)
end

function ENT:GetKicking()
	if SERVER then
		return self.Kicking
	end
	return self:GetNWBool("MelonKicking", bool)
end

function ENT:GetCreateTime()
	return self.CreateTime
end