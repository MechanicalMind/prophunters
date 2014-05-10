local PlayerMeta = FindMetaTable("Player")

util.AddNetworkString("gamestate")
util.AddNetworkString("round_victor")
util.AddNetworkString("gamerules")

GM.GameState = GAMEMODE and GAMEMODE.GameState or 0
GM.StateStart = GAMEMODE and GAMEMODE.StateStart or CurTime()
GM.Rounds = GAMEMODE and GAMEMODE.Rounds or 0

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
	self:NetworkGameState()
end

function GM:NetworkGameState(ply)
	net.Start("gamestate")
	net.WriteUInt(self.GameState or 0, 32)
	net.WriteDouble(self.StateStart or 0)
	net.Broadcast()
end

function GM:GetRoundSettings()
	self.RoundSettings = self.RoundSettings or {}
	return self.RoundSettings 
end

function GM:NetworkGameSettings(ply)
	net.Start("gamerules")

	if self.RoundSettings then
		for k, v in pairs(self.RoundSettings) do
			net.WriteUInt(1, 8)
			net.WriteString(k)
			net.WriteType(v)
		end
	end
	net.WriteUInt(0, 8)

	if ply == nil then
		net.Broadcast()
	else
		net.Send(ply)
	end
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

	self:BalanceTeams()

	for k, ply in pairs(player.GetAll()) do
		if ply:Team() != 1 then // ignore spectators
			ply:SetNWBool("RoundInGame", true)
			ply:KillSilent()
			ply:Spawn()

			local col = team.GetColor(ply:Team())
			ply:SetPlayerColor(Vector(col.r / 255, col.g / 255, col.b / 255))

			if ply:Team() == 2 then
				ply:Freeze(true)
			end
		else
			ply:SetNWBool("RoundInGame", false)
		end
	end
	self:CleanupMap()
	
	self:SetGameState(1)
	self.Rounds = self.Rounds + 1
end

function GM:StartRound()

	self.LastPropDeath = nil
	self.FirstHunterKill = nil

	local hunters, props = 0, 0
	for k, ply in pairs(self:GetPlayingPlayers()) do
		ply:Freeze(false)
		ply.PropDmgPenalty = 0
		ply.PropMovement = 0
		ply.HunterKills = 0
		ply.TauntAmount = 0
		if ply:Team() == 2 then
			hunters = hunters + 1
		elseif ply:Team() == 3 then
			props = props + 1
		end
	end

	local c = 0
	for k, ent in pairs(ents.GetAll()) do
		if ent:IsDisguisableAs() then
			c = c + 1
		end
	end

	self.RoundSettings = {}
	self.RoundSettings.RoundTime = math.Round((c * 0.5 / hunters + 60 * 4)  * math.sqrt(props / hunters))
	print("Round time is " .. (self.RoundSettings.RoundTime / 60) .. " (" .. c .. " props)")

	self:NetworkGameSettings()
	self:SetGameState(2)

	local ct = ChatText()
	ct:Add("Round has started")
	ct:SendAll()

end

function GM:EndRound(reason)
	local winningTeam
	if reason == 1 then
		local ct = ChatText()
		ct:Add("Tie everybody loses")
		ct:SendAll()
	elseif reason == 2 then
		local ct = ChatText()
		ct:Add(team.GetName(2), team.GetColor(2))
		ct:Add(" win")
		ct:SendAll()
		winningTeam = 2
	elseif reason == 3 then
		local ct = ChatText()
		ct:Add(team.GetName(3), team.GetColor(3))
		ct:Add(" win")
		ct:SendAll()
		winningTeam = 3
	end

	self.PlayerAwards = {}

	local propPly, propDmg = nil, 0
	local killsPly, killsAmo = nil, 0
	local movePly, moveAmo
	local tauntsPly, tauntsAmo = nil, 0
	for k, ply in pairs(self:GetPlayingPlayers()) do
		if ply:Team() == 2 then // hunters

			// get hunter with most prop damage
			if ply.PropDmgPenalty > propDmg then
				propDmg = ply.PropDmgPenalty
				propPly = ply
			end

			// get hunter with most kills
			if ply.HunterKills > killsAmo then
				killsAmo = ply.PropDmgPenalty
				killsPly = ply
			end
		else

			// get prop with least movement
			if moveAmo == nil || ply.PropMovement < moveAmo then
				moveAmo = ply.PropMovement
				movePly = ply
			end

			// get prop with most taunts
			if ply.TauntAmount > tauntsAmo then
				tauntsAmo = ply.TauntAmount
				tauntsPly = ply
			end
		end
	end

	if propPly then
		self.PlayerAwards["PropDamage"] = propPly
	end

	if movePly then
		self.PlayerAwards["LeastMovement"] = movePly
	end
	
	if killsPly then
		self.PlayerAwards["MostKills"] = killsPly
	end

	if tauntsPly then
		self.PlayerAwards["MostTaunts"] = tauntsPly
	end

	// last prop death award
	if IsValid(self.LastPropDeath) && reason == 2 then
		self.PlayerAwards["LastPropStanding"] = self.LastPropDeath
	end

	// first hunter kill award
	if IsValid(self.FirstHunterKill) then
		self.PlayerAwards["FirstHunterKill"] = self.FirstHunterKill
	end

	net.Start("round_victor")
	net.WriteUInt(reason, 8)
	if winningTeam then
		net.WriteUInt(winningTeam, 16)
	end
	for k, v in pairs(self.PlayerAwards) do
		net.WriteUInt(1, 8)
		net.WriteString(tostring(k))
		net.WriteEntity(v)
		net.WriteVector(v:GetPlayerColor())
		net.WriteString(v:Nick())
	end
	net.WriteUInt(0, 8)
	net.Broadcast()

	self.RoundSettings.NextRoundTime = 25
	self:NetworkGameSettings()

	for k, ply in pairs(self:GetPlayingPlayers()) do
		if ply:Team() == winningTeam then
		else
		end
	end
	self:AddRoundStatistic(self:GetStateRunningTime(), #self:GetPlayingPlayers())
	self:SetGameState(3)
end

function GM:RoundsSetupPlayer(ply)
	// start off not participating
	ply:SetNWBool("RoundInGame", false)

	// send game state
	self:NetworkGameState(ply)
end

function GM:CheckForVictory()
	local settings = self:GetRoundSettings()
	local roundTime = settings.RoundTime or 5 * 60
	if self:GetStateRunningTime() > roundTime then
		self:EndRound(3)
		return
	end

	local red, blue = 0, 0
	for k, ply in pairs(self:GetPlayingPlayers()) do
		if ply:Alive() then
			if ply:Team() == 2 then
				red = red + 1
			elseif ply:Team() == 3 then
				blue = blue + 1
			end
		end
	end
	if red == 0 && blue == 0 then
		self:EndRound(1)
		return
	end

	if red == 0 then
		self:EndRound(3)
		return
	end
	if blue == 0 then
		self:EndRound(2)
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
		if self:GetStateRunningTime() > 30 then
			self:StartRound()
		end
	elseif self:GetGameState() == 2 then
		self:CheckForVictory()

		for k, ply in pairs(self:GetPlayingPlayers()) do
			if ply:Team() == 3 then
				ply.PropMovement = (ply.PropMovement or 0) + ply:GetVelocity():Length()
			end
		end
	elseif self:GetGameState() == 3 then
		if self:GetStateRunningTime() > (self.RoundSettings.NextRoundTime or 30) then
			self:SwapTeams()
			self:SetupRound()
		end
	end
end

function GM:DoRoundDeaths(ply, attacker)

end

function PlayerMeta:SetScore(score)
	self:SetNWInt("MelonScore", score)
end

function PlayerMeta:GetScore()
	return self:GetNWInt("MelonScore") or 0
end