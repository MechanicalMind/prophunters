
util.AddNetworkString("kill_feed_add")

function GM:AddKillFeed(ply, inflictor, attacker)
	net.Start("kill_feed_add")
	net.WriteEntity(ply)
	net.WriteEntity(inflictor)
	net.WriteEntity(attacker)
	if ply.LastDamageInfo then
		net.WriteUInt(ply.LastDamageInfo:GetDamageType(), 32)
	else
		net.WriteUInt(0, 32)
	end
	net.Broadcast()
end
