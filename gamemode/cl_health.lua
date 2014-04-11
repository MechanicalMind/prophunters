local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:GetHMaxHealth()
	return self:GetNWFloat("HMaxHealth", 100) or 100
end