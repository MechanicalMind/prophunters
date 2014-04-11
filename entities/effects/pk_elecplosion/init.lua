
function EFFECT:Init( data )

	self.StartTime = CurTime()
	self.NextFlame = CurTime()

	self.pos = data:GetOrigin()
	self.Scale = data:GetScale()
	self.Mag = data:GetMagnitude()
			
	self.Emitter = ParticleEmitter( self.pos ) 

	for i = 1, 20 do
		
		local t = VectorRand() * self.Scale
		t.z = math.abs(t.z)
		local particle = self.Emitter:Add( "Effects/fire_embers" .. math.random(1,3), self.pos + t)
		local v = VectorRand() * 20
		v.z = 40
		particle:SetVelocity( v )
		particle:SetGravity(Vector(0, 0, -120))
		particle:SetDieTime( 1.2)
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 255 )
		particle:SetStartSize( 5 )
		particle:SetEndSize( 0 )   
		particle:SetRoll( math.random(0,360) )
		//particle:SetRollDelta( 0 )
		if self.Mag > 1 then
			particle:SetStartSize(6)
		else
			particle:SetColor(255, 255, 255)
		end
		
		
	end

	for i = 1, 10 do
		local t = VectorRand() * self.Scale * 0.7
		t.z = math.abs(t.z)
		local particle = self.Emitter:Add( "Effects/fire_cloud" .. math.random(1,2), self.pos + t)
		particle:SetVelocity( VectorRand() * 0 )
		particle:SetDieTime( 0.4)
		particle:SetStartAlpha( 150 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 20 )
		particle:SetEndSize( 25 )   
		particle:SetRoll( math.random(0,360) )
		//particle:SetRollDelta( 0 )
		particle:SetColor( 255,255,255 )

		if self.Mag > 1 then
			particle:SetColor(150, 150, 255, 255)
			particle:SetStartSize(25)
			particle:SetEndSize(35)
		else
			particle:SetColor(255, 255, 255)
		end
	end
	
	for i = 1, 7 do
		
		-- local particle = self.Emitter:Add( "particle/particle_smokegrenade1", self.pos + VectorRand() * self.Scale / 2)
		local t = VectorRand() * self.Scale * 0.7
		t.z = math.abs(t.z)
		local particle = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1, 9), self.pos + t)
		particle:SetVelocity( VectorRand(0, 0, 10) )
		particle:SetDieTime( 5.2)
		particle:SetStartAlpha( 50 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 30 )
		particle:SetEndSize( 50 )   
		particle:SetRoll( math.random(0,360) )
		//particle:SetRollDelta( 0 )
		particle:SetColor( 150, 150, 150 )
		
	end
		
	
end

function EFFECT:Think( )
	if self.StartTime + 0.5 < CurTime() then
		self.Emitter:Finish()
		return false
	end

	if self.NextFlame + 0.1 < CurTime() then
		self.NextFlame = CurTime()

		-- local t = VectorRand() * self.Scale
		-- t.z = math.abs(t.z)
		-- local particle = self.Emitter:Add( "Effects/fire_embers" .. math.random(1,3), self.pos + t)
		-- local v = VectorRand() * 40
		-- v.z = 30
		-- particle:SetVelocity( v )
		-- particle:SetDieTime( 1.2)
		-- particle:SetStartAlpha( 255 )
		-- particle:SetEndAlpha( 255 )
		-- particle:SetStartSize( 4 )
		-- particle:SetEndSize( 0 )   
		-- particle:SetRoll( math.random(0,360) )
		-- //particle:SetRollDelta( 0 )
		-- particle:SetColor( 255,255,255 )
	end

	return true
end

function EFFECT:Render()
end
