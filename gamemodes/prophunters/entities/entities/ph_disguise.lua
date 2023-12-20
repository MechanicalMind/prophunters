
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Disguise Ent"
ENT.Author			= "Mechanical Mind"
ENT.Information		= ""
ENT.Category		= ""

ENT.Editable			= true
ENT.Spawnable			= true
ENT.AdminOnly			= false
ENT.RenderGroup 		= RENDERGROUP_BOTH

function ENT:SetupDataTables()

end


function ENT:Initialize()

	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
	else 
		
	end
	
end

if ( CLIENT ) then

	function ENT:Draw()
		self:DrawModel()
	end

end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:OnTakeDamage( dmginfo )
end

function ENT:Use( ply, caller )
end

function ENT:Think()
	if IsValid(self.PropOwner) then
		self:SetPos(self.PropOwner:GetPos())
	end
	self:NextThink(CurTime() + 0.05)
	return true
end