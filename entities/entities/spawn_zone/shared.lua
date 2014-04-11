
ENT.Base = "base_entity"
ENT.Type = "brush"

AddCSLuaFile( "shared.lua" )

function ENT:Initialize()
end

function ENT:StartTouch( entity )


end

function ENT:KeyValue( key, value )

end

function ENT:PassesTriggerFilters( entity )
	return false
end
