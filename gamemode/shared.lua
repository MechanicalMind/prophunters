GM.Name 	= "Codename Bluesubmarine"
GM.Author 	= "MechanicalMind"
// Credits to waddlesworth for the logo and icon
GM.Email 	= ""
GM.Website 	= "http://codingconcoctions.com/"
GM.Version 	= "0.0.1"

team.SetUp(1, "Spectators", Color(50, 50, 50))
team.SetUp(2, "Hunters", Color(255, 150, 50))
team.SetUp(3, "Props", Color(50, 150, 255))

function GM:ShouldCollide(ent1, ent2)
	if !IsValid(ent1) then return true end
	if !IsValid(ent2) then return true end

	// nocollide players
	if ent1:IsPlayer() && ent2:IsPlayer() then
		-- if ent1:Team() == ent2:Team() then
			return false
		-- end
	end
	return true
end

function GM:PlayerSetNewHull(ply, s, z, duckz)
	s = s or 32
	z = z or 72
	duckz = duckz or z / 2
	ply:SetHull(Vector(-s, -s, 0), Vector(s, s, z))
	ply:SetHullDuck(Vector(-s, -s, 0), Vector(s, s, duckz))

	if SERVER then
		net.Start("hull_set")
		net.WriteEntity(ply)
		net.WriteFloat(s)
		net.WriteFloat(z)
		net.WriteFloat(duckz)
		net.Broadcast()
		// TODO send on player spawn
	end
end