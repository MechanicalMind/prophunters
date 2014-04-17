
function EFFECT:Init( data )

	self.StartTime = CurTime()
	self.NextFlame = CurTime()

	self.pos = data:GetOrigin()
	self.Scale = data:GetScale()
	self.Mag = data:GetMagnitude()
			
	self.Emitter = ParticleEmitter( self.pos ) 
	
	for i = 1, 17 do
		
		-- local particle = self.Emitter:Add( "particle/particle_smokegrenade1", self.pos + VectorRand() * self.Scale / 2)
		local t = Vector(math.Rand(-self.Scale, self.Scale), math.Rand(-self.Scale, self.Scale), math.Rand(0, self.Mag))
		local particle = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1, 9), self.pos + t)
		particle:SetVelocity( t:GetNormal() )
		particle:SetDieTime( 5.2)
		particle:SetStartAlpha( 20 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( self.Scale * 2 )
		particle:SetEndSize( self.Scale * 2 )   
		particle:SetRoll( math.random(0,360) )
		//particle:SetRollDelta( 0 )
		local i = math.random(50, 150)
		particle:SetColor( i, i, i )

	end

		
	
end

function EFFECT:Think( )
	-- if self.StartTime + 0.5 < CurTime() then
		self.Emitter:Finish()
		return false
	-- end
end

function EFFECT:Render()
end
