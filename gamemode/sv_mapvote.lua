// mapvote

util.AddNetworkString("ph_mapvote")
util.AddNetworkString("ph_mapvotevotes")

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
	print("[Prophunters] Rotate changing map to " .. nextMap)
	local ct = ChatText()
	ct:Add(Translator:QuickVar(translate.mapChange, "map", nextMap))
	ct:SendAll()
	hook.Call("OnChangeMap", GAMEMODE)
	timer.Simple(5, function ()
		RunConsoleCommand("changelevel", nextMap)
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
end

function GM:StartMapVote()
	self.MapVoteStart = CurTime()
	self.MapVoteTime = 30
	self.MapVotes = {}

	self:SetGameState(4)
	self:NetworkMapVoteStart()
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