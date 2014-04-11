local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:ResetUpgrades()
	self.MaxBombs = 1
	self.RunningBoots = 1
	self.PowerUps = 1
	self.Upgrades = {}
	hook.Call("PlayerResetUpgrades", self)
	self:NetworkUpgrades()
end

function PlayerMeta:GetMaxBombs()
	return self.MaxBombs or 1
end

function PlayerMeta:SetMaxBombs(amo)
	self.MaxBombs = math.Clamp(amo or 1, 1, 9)
	self:NetworkUpgrades()
end

function PlayerMeta:GetRunningBoots()
	return self.RunningBoots or 1
end

function PlayerMeta:SetRunningBoots(amo)
	self.RunningBoots = math.Clamp(amo or 1, 1, 9)
	self:CalculateSpeed()
	self:NetworkUpgrades()
end

function PlayerMeta:GetBombPower()
	return self.PowerUps or 1
end

function PlayerMeta:SetBombPower(amo)
	self.PowerUps = math.Clamp(amo or 1, 1, 9)
	self:NetworkUpgrades()
end

util.AddNetworkString("melons_upgrades")
function PlayerMeta:NetworkUpgrades()
	net.Start("melons_upgrades")
	net.WriteUInt(self:GetRunningBoots(), 8)
	net.WriteUInt(self:GetMaxBombs(), 8)
	net.WriteUInt(self:GetBombPower(), 8)
	for k, v in pairs(self.Upgrades) do
		net.WriteUInt(v, 16)
	end
	net.WriteUInt(0, 16)
	net.Send(self)
end

util.AddNetworkString("melons_pickup_upgrade")
function PlayerMeta:AddUpgrade(key)
	table.insert(self.Upgrades, key)
	net.Start("melons_pickup_upgrade")
	net.WriteUInt(key, 16)
	net.Send(self)
	self:NetworkUpgrades()
end

function PlayerMeta:HasUpgrade(key)
	for k, v in pairs(self.Upgrades) do
		if v == key then
			return true
		end
	end
	return false
end
