GM.Name 	= "Codename Bluesubmarine"
GM.Author 	= "MechanicalMind"
// Credits to waddlesworth for the logo and icon
GM.Email 	= ""
GM.Website 	= "http://codingconcoctions.com/"
GM.Version 	= "0.0.1"

team.SetUp(1, "Spectators", Color(50, 50, 50))
team.SetUp(2, "Player", Color(150, 150, 150))

local up = Vector(0, 0, 1):Angle()

function GM:Move( ply, mv )

end

function GM:SetupMove(ply, mv)
end

function GM:FinishMove(ply, mv)

end

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

function GM:PlayerSetNewHull(ply, s)
	s = s or 32
	ply:SetHull(Vector(-s / 2, -s / 2, 0), Vector(s / 2, s / 2, 72))
	ply:SetHullDuck(Vector(-s / 2, -s / 2, 0), Vector(s / 2, s / 2, 36))
end