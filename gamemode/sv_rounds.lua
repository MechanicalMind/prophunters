local PlayerMeta = FindMetaTable("Player")

util.AddNetworkString("gamestate")
util.AddNetworkString("round_victor")

GM.GameState = GAMEMODE and GAMEMODE.GameState or 0
GM.StateStart = GAMEMODE and GAMEMODE.StateStart or CurTime()
GM.Rounds = GAMEMODE and GAMEMODE.Rounds or 0

team.SetUp(1, "Spectators", Color(150, 150, 150))

// STATES
// 0 WAITING FOR PLAYERS
// 1 STARTING ROUND
// 2 PLAYING
// 3 END GAME RESET TIME

function GM:GetGameState()
	return self.GameState
end

function GM:GetStateStart()
	return self.StateStart
end

function GM:GetStateRunningTime()
	return CurTime() - self.StateStart
end

function GM:GetPlayingPlayers()
	local players = {}
	for k, ply in pairs(player.GetAll()) do
		if ply:Team() != 1 && ply:GetNWBool("RoundInGame") then
			table.insert(players, ply)
		end
	end
	return players
end

function GM:SetGameState(state)
	self.GameState = state
	self.StateStart = CurTime()
	net.Start("gamestate")
	net.WriteUInt(self.GameState, 32)
	net.WriteDouble(self.StateStart)
	net.Broadcast()
end

function GM:SetupRound()
	local c = 0
	for k, ply in pairs(player.GetAll()) do
		if ply:Team() != 1 then // ignore spectators
			c = c + 1
		end
	end
	if c < 2 then
		local ct = ChatText()
		ct:Add("Not enough players to start round")
		ct:SendAll()
		self:SetGameState(0)
		return
	end

	local i = 1
	for k, ply in pairs(player.GetAll()) do
		if ply:Team() != 1 then // ignore spectators
			ply:SetNWBool("RoundInGame", true)
			ply:KillSilent()
			ply:Spawn()

			local col = self:AssignColor(i, c)
			ply:SetPlayerColor(Vector(col.r / 255, col.g / 255, col.b / 255))
			i = i + 1

			ply:Freeze(true)
		else
			ply:SetNWBool("RoundInGame", false)
		end
	end
	self:CleanupMap()
	
	self:SetGameState(1)
	self.Rounds = self.Rounds + 1
end

function GM:StartRound()
	self:SetGameState(2)

	for k, ply in pairs(self:GetPlayingPlayers()) do
		ply:Freeze(false)
	end

	local ct = ChatText()
	ct:Add("Round has started")
	ct:SendAll()

end

function GM:EndRound(reason, winner)
	self.RoundWinner = winner
	
	if reason == 1 then
		local ct = ChatText()
		ct:Add("Tie everybody loses")
		ct:SendAll()

		net.Start("round_victor")
		net.WriteUInt(reason, 8)
		net.Broadcast()

	elseif reason == 2 then
		winner:SetScore(winner:GetScore() + 1)

		net.Start("round_victor")
		net.WriteUInt(reason, 8)
		net.WriteEntity(winner)
		net.WriteString(winner:Nick())
		net.WriteVector(winner:GetPlayerColor())
		net.WriteUInt(winner:GetScore(), 16)
		net.Broadcast()

		local ct = ChatText()
		local col = winner:GetPlayerColor()
		col = Color(col.r * 255, col.g * 255, col.b * 255)
		ct:Add(winner:Nick(), col)
		ct:Add(" wins")
		ct:SendAll()
	end

	for k, ply in pairs(self:GetPlayingPlayers()) do
		
	end
	self:AddRoundStatistic(self:GetStateRunningTime(), #self:GetPlayingPlayers())
	self:SetGameState(3)
end

function GM:RoundsSetupPlayer(ply)
	// start off not participating
	ply:SetNWBool("RoundInGame", false)

	// send game state
	net.Start("gamestate")
	net.WriteUInt(self.GameState, 32)
	net.WriteDouble(self.StateStart)
	net.Send(ply)
end

function GM:CheckForVictory()
	local c = 0
	local last
	for k, ply in pairs(self:GetPlayingPlayers()) do
		if ply:Alive() then
			c = c + 1
			last = ply
		end
	end

	if c == 0 then
		self:EndRound(1)
		return
	end

	if c == 1 then
		self:EndRound(2, last)
		return
	end
end

function GM:RoundsThink()
	if self:GetGameState() == 0 then
		local c = 0
		for k, ply in pairs(player.GetAll()) do
			if ply:Team() != 1 then // ignore spectators
				c = c + 1
			end
		end
		if c >= 2 then
			self:SetupRound()
		end
	elseif self:GetGameState() == 1 then
		if self:GetStateRunningTime() > 5 then
			self:StartRound()
		end
	elseif self:GetGameState() == 2 then
		self:CheckForVictory()
	elseif self:GetGameState() == 3 then
		if self:GetStateRunningTime() > 10 then
			self:SetupRound()
		end
	end
end

function GM:DoRoundDeaths(ply, attacker)

end

local colors = {
	HSVToColor(0, 0.7, 0.98),
	HSVToColor(110, 0.79, 0.9),
	HSVToColor(240, 0.8, 0.93),
	HSVToColor(60, 0.85, 0.94),
	HSVToColor(270, 0.81, 0.94),
	HSVToColor(30, 0.97, 0.93),
	HSVToColor(340, 0.77, 0.96),
	HSVToColor(190, 0.99, 0.98),
	HSVToColor(300, 0.71, 0.95),
	HSVToColor(80, 0.89, 0.57),
	HSVToColor(259, 0.87, 0.57),
	HSVToColor(120, 0.98, 0.39),
}

function GM:AssignColor(i, count)
	-- if count <= #colors then
	-- 	col = table.Copy(colors[i])
	-- 	return col
	-- end
	i = i - 1
	-- local hue = i / count * 360 + math.Rand(0, i / count / 2)
	local v = (i % 3) / 3
	local hue = (i * 360 / 1.61803) % 360
	local col = HSVToColor(hue, math.Rand(0.7, 1), 0.7 + v * 0.3)
	return col
end

function GM:TestColors(count)
	count = count or 1
	local ct = ChatText()
	for i = 1, count do
		local col = self:AssignColor(i, count)
		ct:Add("player " .. i .. ", ", col)
		local h, s, v = ColorToHSV(col)
		-- print("player " .. i, "HSVToColor(" .. h .. ", " .. math.Round(s * 100) / 100 .. ", " .. math.Round(v * 100) / 100 .. ")")
		-- print("Color(" .. col.r .. ", " .. col.g .. ", " .. col.b .. ")")
	end
	ct:SendAll()
end


function PlayerMeta:SetScore(score)
	self:SetNWInt("MelonScore", score)
end

function PlayerMeta:GetScore()
	return self:GetNWInt("MelonScore") or 0
end