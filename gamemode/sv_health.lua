
local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:SetHMaxHealth(amo)
	self.HMaxHealth = amo
	self:SetNWFloat("HMaxHealth", amo)
	self:SetMaxHealth(amo)
end

function PlayerMeta:GetHMaxHealth()
	return self.HMaxHealth or 100
end