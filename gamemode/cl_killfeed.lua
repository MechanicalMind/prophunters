GM.KillFeed = {}


net.Receive("kill_feed_add", function (len)
	local ply = net.ReadEntity()
	local attacker = net.ReadEntity()
	local damageType = net.ReadUInt(32)
	if !IsValid(ply) then return end
	-- print(ply, attacker, damageType)
	-- if damageType != 0 then
	-- 	local i = 1
	-- 	for c = 1, 30 do
	-- 		i = i * 2
	-- 		print(i, "", bit.band(damageType, i))
	-- 	end
	-- end

	local t = {}
	t.time = CurTime()
	t.player = ply
	t.playerName = ply:Nick()
	local col = ply:GetPlayerColor()
	t.playerColor = Color(col.x * 255, col.y * 255, col.z * 255)
	t.attacker = attacker
	t.damageType = damageType
	if bit.band(damageType, DMG_FALL) == DMG_FALL then
		t.message = "pushed to their death"
		t.messageSelf = "fell to their death"
	end
	if bit.band(damageType, DMG_BULLET) == DMG_BULLET then
		t.message = table.Random({
			"shot",
			"fed lead to",
			"swiss cheesed"
		})
		t.messageSelf = "shot themself"
	end
	if bit.band(damageType, DMG_BURN) == DMG_BURN then
		t.message = "burned to death"
		t.messageSelf = "burned to death"
	end
	if bit.band(damageType, DMG_CRUSH) == DMG_CRUSH then
		t.message = "threw a prop at"
		t.messageSelf = "was crushed to death"
	end
	if bit.band(damageType, DMG_BUCKSHOT) == DMG_BUCKSHOT then
		t.message = table.Random({
			"peppered with buckshot",
			"shotgunned",
		})
	end
	if bit.band(damageType, DMG_AIRBOAT) == DMG_AIRBOAT then
		t.messageSelf = "shot too many props"
	end
	if damageType == 0 then
		t.messageSelf = table.Random({
			"fell over",
			"tripped",
			"couldn't take it",
			"killed themself"
		})
	end
	if IsValid(attacker) && attacker:IsPlayer() && attacker != ply then
		t.attackerName = attacker:Nick()
		local col = attacker:GetPlayerColor()
		t.attackerColor = Color(col.x * 255, col.y * 255, col.z * 255)
		Msg(attacker:Nick() .. " " .. (t.message or "killed") .. " " .. ply:Nick() .. "\n")
	else
		Msg(ply:Nick() .. " " .. (t.messageSelf or "killed themself") .. "\n")
	end

	table.insert(GAMEMODE.KillFeed, t)
end)

function GM:DrawKillFeed()
	local gap = draw.GetFontHeight("RobotoHUD-15") + 4
	local down = 0
	local k = 1
	while true do
		if k > #GAMEMODE.KillFeed then
			break
		end
		local t = GAMEMODE.KillFeed[k]
		if t.time + 30 < CurTime() then
			table.remove(self.KillFeed, k)
		else
			surface.SetFont("RobotoHUD-15")
			local twp, thp = surface.GetTextSize(t.playerName)

			if t.attackerName then
				local killed = " " .. (t.message or "killed") .. " "
				local twa, tha = surface.GetTextSize(t.attackerName)
				local twk, thk = surface.GetTextSize(killed)
				draw.ShadowText(t.attackerName, "RobotoHUD-15", ScrW() - 4 - twp - twk - twa, 4 + down * gap, t.attackerColor, 0)
				draw.ShadowText(killed, "RobotoHUD-15", ScrW() - 4 - twp - twk, 4 + down * gap, color_white, 0)
				draw.ShadowText(t.playerName, "RobotoHUD-15", ScrW() - 4 - twp, 4 + down * gap, t.playerColor, 0)
			else
				local killed = " " .. (t.messageSelf or "killed themself")
				local twk, thk = surface.GetTextSize(killed)

				draw.ShadowText(killed, "RobotoHUD-15", ScrW() - 4 - twk, 4 + down * gap, color_white, 0)
				draw.ShadowText(t.playerName, "RobotoHUD-15", ScrW() - 4 - twp - twk, 4 + down * gap, t.playerColor, 0)
			end

			down = down + 1
			k = k + 1
		end
	end
end

