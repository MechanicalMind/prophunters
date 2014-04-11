

function GM:BotMove(ply, cmd)
	local zone, x, y = self:GetGridPosFromEnt(ply)
	if zone then
		// TODO add beter bot ai
		if ply.BotTarget then
			x = ply.BotTarget.x
			y = ply.BotTarget.y
		end
		local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
		local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
		t.z = zone:OBBMins().z

		local look = t - ply:GetPos()
		look.z = 0
		if look:Length() > 4 then
			if look:Length() > zone.grid.sqsize then
				ply.BotTarget = nil
			end
			cmd:SetViewAngles(look:Angle())
			cmd:SetForwardMove(50)
		else
			local yaw = Angle(0, math.random(0, 3) * 90, 0)
			local add = yaw:Forward()
			add.x = math.Round(add.x)
			add.y = math.Round(add.y)
			if self:IsGridPosClear(zone, x + add.x, y + add.y, true) then
				ply.BotTarget = Vector(x + add.x, y + add.y)
			end
		end
	end
end