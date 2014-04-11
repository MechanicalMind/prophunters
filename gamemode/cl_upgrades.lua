GM.Upgrades = {}

function GM:GetMaxBombs()
	return self.MaxBombs or 1
end

function GM:GetRunningBoots()
	return self.RunningBoots or 1
end

function GM:GetBombPower()
	return self.PowerUps or 1
end

function GM:HasUpgrade(key)
	for k, v in pairs(self.Upgrades) do
		if v == key then
			return true
		end
	end
	return false
end

net.Receive("melons_upgrades", function (len)
	GAMEMODE.RunningBoots = net.ReadUInt(8)
	GAMEMODE.MaxBombs = net.ReadUInt(8)
	GAMEMODE.PowerUps = net.ReadUInt(8)
	GAMEMODE.Upgrades = {}
	while true do
		local v = net.ReadUInt(16)
		if v == 0 then break end
		table.insert(GAMEMODE.Upgrades, v)
	end
end)