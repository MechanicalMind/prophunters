
util.AddNetworkString("kill_feed_add")

function GM:AddKillFeed(ply, attacker, dmginfo)
	net.Start("kill_feed_add")
	net.WriteEntity(ply)
	net.WriteEntity(attacker)
	net.WriteUInt(dmginfo:GetDamageType(), 32)
	net.Broadcast()
end
