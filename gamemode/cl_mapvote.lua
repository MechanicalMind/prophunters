GM.MapVoteTime = GAMEMODE and GAMEMODE.MapVoteTime or 30
GM.MapVoteStart = GAMEMODE and GAMEMODE.MapVoteStart or CurTime()

net.Receive("ph_mapvote", function (len)
	GAMEMODE.MapVoteStart = net.ReadFloat()
	GAMEMODE.MapVoteTime = net.ReadFloat()

	local mapList = {}

	while true do
		local k = net.ReadUInt(16)
		if k <= 0 then break end
		local map = net.ReadString()
		table.insert(mapList, map)
	end
	
	GAMEMODE.MapList = mapList
	GAMEMODE:EndRoundMapVote()
end)

net.Receive("ph_mapvotevotes", function (len)

	local mapVotes = {}

	while true do
		local k = net.ReadUInt(8)
		if k <= 0 then break end
		local ply = net.ReadEntity()
		local map = net.ReadString()
		mapVotes[ply] = map
	end
	
	GAMEMODE.MapVotes = mapVotes
end)

function GM:GetMapVoteStart()
	return self.MapVoteStart
end

function GM:GetMapVoteRunningTime()
	return CurTime() - self.MapVoteStart
end