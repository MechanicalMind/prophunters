// mapvote

util.AddNetworkString("ph_mapvote")
util.AddNetworkString("ph_mapvotevotes")

GM.MapVoteTime = GAMEMODE and GAMEMODE.MapVoteTime or 30
GM.MapVoteStart = GAMEMODE and GAMEMODE.MapVoteStart or CurTime()

function GM:IsMapVoting()
	return self.MapVoting
end

function GM:GetMapVoteStart()
	return self.MapVoteStart
end

function GM:GetMapVoteRunningTime()
	return CurTime() - self.MapVoteStart
end

function GM:RotateMap()
	local map = game.GetMap()
	local index 
	for k, map2 in pairs(self.MapList) do
		if map == map2 then
			index = k
		end
	end
	if !index then index = 1 end
	index = index + 1
	if index > #self.MapList then
		index = 1
	end
	local nextMap = self.MapList[index]
	self:ChangeMapTo(map)
end

function GM:ChangeMapTo(map)
	if map == game.GetMap() then
		self.Rounds = 0
		self:SetGameState(0)
		return
	end
	print("[Prophunters] Rotate changing map to " .. map)
	local ct = ChatText()
	ct:Add("Changing map to " .. map)
	ct:SendAll()
	hook.Call("OnChangeMap", GAMEMODE)
	timer.Simple(5, function ()
		RunConsoleCommand("changelevel", map)
	end)
end

GM.MapList = {}

local defaultMapList = {
	"cs_italy",
	"cs_office",
	"cs_compound",
	"cs_assault"
}

function GM:SaveMapList()

	// ensure the folders are there
	if !file.Exists("prophunters/","DATA") then
		file.CreateDir("prophunters")
	end

	local txt = ""
	for k, map in pairs(self.MapList) do
		txt = txt .. map .. "\r\n"
	end
	file.Write("prophunters/maplist.txt", txt)
end

function GM:LoadMapList() 
	local jason = file.ReadDataAndContent("prophunters/maplist.txt")
	if jason then
		local tbl = {}
		local i = 1
		for map in jason:gmatch("[^\r\n]+") do
			table.insert(tbl, map)
		end
		self.MapList = tbl
	else
		local tbl = {}

		for k, map in pairs(defaultMapList) do
			if file.Exists("maps/" .. map .. ".bsp", "GAME") then
				table.insert(tbl, map)
			end
		end

		local files, dirs = file.Find("maps/*", "GAME")
		for k, v in pairs(files) do
			local name = v:match("([^%.]+)%.bsp$")
			if name then
				if name:sub(1, 3) == "ph_" then
					table.insert(tbl, name)
				end
			end
		end
		self.MapList = tbl
		self:SaveMapList()
	end

	for k, map in pairs(self.MapList) do
		local path = "maps/" .. map .. ".png"
		if file.Exists(path, "GAME") then
			resource.AddSingleFile(path)
		else
			local path = "maps/thumb/" .. map .. ".png"
			if file.Exists(path, "GAME") then
				resource.AddSingleFile(path)
			end
		end
	end
end

function GM:StartMapVote()
	self.MapVoteStart = CurTime()
	self.MapVoteTime = 30
	self.MapVoting = true
	self.MapVotes = {}

	// randomise the order of maps so people choose different ones
	local maps = {}
	for k, v in pairs(self.MapList) do
		table.insert(maps, math.random(#maps) + 1, v)
	end
	self.MapList = maps

	// make bots vote for a map
	-- for k, ply in pairs(player.GetAll()) do
	-- 	if ply:IsBot() then
	-- 		self.MapVotes[ply] = maps[math.random(#maps)]
	-- 	end
	-- end

	self:SetGameState(4)
	self:NetworkMapVoteStart()
end

function GM:MapVoteThink()
	if self.MapVoting then
		if self:GetMapVoteRunningTime() >= self.MapVoteTime then
			self.MapVoting = false
			local votes = {}
			for ply, map in pairs(self.MapVotes) do
				if IsValid(ply) && ply:IsPlayer() then
					votes[map] = (votes[map] or 0) + 1
				end
			end

			local maxvotes = 0
			for k, v in pairs(votes) do
				if v > maxvotes then
					maxvotes = v
				end
			end

			local maps = {}
			for k, v in pairs(votes) do
				if v == maxvotes then
					table.insert(maps, k)
				end
			end

			if #maps > 0 then
				self:ChangeMapTo(table.Random(maps))
			else
				local ct = ChatText()
				ct:Add("Map change failed, not enough votes")
				ct:SendAll()
				print("Map change failed, not enough votes")
				self:SetGameState(0)
			end
		end
	end
end

function GM:NetworkMapVoteStart(ply)
	net.Start("ph_mapvote")
	net.WriteFloat(self.MapVoteStart)
	net.WriteFloat(self.MapVoteTime)

	for k, map in pairs(self.MapList) do
		net.WriteUInt(k, 16)
		net.WriteString(map)
	end
	net.WriteUInt(0, 16)


	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end

	self:NetworkMapVotes()
end

function GM:NetworkMapVotes(ply)
	net.Start("ph_mapvotevotes")

	for k, map in pairs(self.MapVotes) do
		net.WriteUInt(1, 8)
		net.WriteEntity(k)
		net.WriteString(map)
	end
	net.WriteUInt(0, 8)


	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

concommand.Add("ph_votemap", function (ply, com, args)
	if GAMEMODE.MapVoting then
		if #args < 1 then
			return
		end

		local found
		for k, v in pairs(GAMEMODE.MapList) do
			if v:lower() == args[1]:lower() then
				found = v
				break
			end
		end
		if !found then
			ply:ChatPrint("Invalid map " .. args[1])
			return
		end

		GAMEMODE.MapVotes[ply] = found
		GAMEMODE:NetworkMapVotes()
	end
end)