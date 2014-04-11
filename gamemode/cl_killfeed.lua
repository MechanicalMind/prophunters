GM.KillFeed = {}


net.Receive("kill_feed_add", function (len)
	local ply = net.ReadEntity()
	local inflictor = net.ReadEntity()
	local attacker = net.ReadEntity()
	local damageType = net.ReadUInt(32)
	if !IsValid(ply) then return end

	local t = {}
	t.time = CurTime()
	t.player = ply
	t.playerName = ply:Nick()
	local col = ply:GetPlayerColor()
	t.playerColor = Color(col.x * 255, col.y * 255, col.z * 255)
	t.inflictor = inflictor
	t.attacker = attacker
	t.damageType = damageType
	if IsValid(attacker) && attacker:IsPlayer() && attacker != ply then
		t.attackerName = attacker:Nick()
		local col = attacker:GetPlayerColor()
		t.attackerColor = Color(col.x * 255, col.y * 255, col.z * 255)
		Msg(attacker:Nick() .. " killed " .. ply:Nick() .. "\n")
	elseif damageType == DMG_AIRBOAT then
		Msg("Death blocks killed " .. ply:Nick() .. "\n")
	else
		Msg(ply:Nick() .. " killed themselves\n")
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
				local killed = " killed "
				local twa, tha = surface.GetTextSize(t.attackerName)
				local twk, thk = surface.GetTextSize(killed)
				draw.ShadowText(t.attackerName, "RobotoHUD-15", ScrW() - 4 - twp - twk - twa, 4 + down * gap, t.attackerColor, 0)
				draw.ShadowText(killed, "RobotoHUD-15", ScrW() - 4 - twp - twk, 4 + down * gap, color_white, 0)
				draw.ShadowText(t.playerName, "RobotoHUD-15", ScrW() - 4 - twp, 4 + down * gap, t.playerColor, 0)
			elseif t.damageType == DMG_AIRBOAT then
				local killed = " killed "
				local twa, tha = surface.GetTextSize("Death blocks")
				local twk, thk = surface.GetTextSize(killed)
				draw.ShadowText("Death blocks", "RobotoHUD-15", ScrW() - 4 - twp - twk - twa, 4 + down * gap, Color(220, 30, 30), 0)
				draw.ShadowText(killed, "RobotoHUD-15", ScrW() - 4 - twp - twk, 4 + down * gap, color_white, 0)
				draw.ShadowText(t.playerName, "RobotoHUD-15", ScrW() - 4 - twp, 4 + down * gap, t.playerColor, 0)
			else
				local killed = " killed themself"
				local twk, thk = surface.GetTextSize(killed)

				draw.ShadowText(killed, "RobotoHUD-15", ScrW() - 4 - twk, 4 + down * gap, color_white, 0)
				draw.ShadowText(t.playerName, "RobotoHUD-15", ScrW() - 4 - twp - twk, 4 + down * gap, t.playerColor, 0)
			end

			down = down + 1
			k = k + 1
		end
	end
end

