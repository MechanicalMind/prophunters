
function GM:RealismThink()
 	for k, ply in pairs(player.GetAll()) do

 		if ply:Alive() then
			local running = ply:GetVelocity():LengthSqr() > 1
			local onground = ply:OnGround()

			// don't increase velocity when jumping off ground
			if ply:KeyPressed(IN_JUMP) && ply.PrevOnGround then
				ply.LastJump = CurTime()

				local curVel = ply:GetVelocity()
				local newVel = ply.PrevSpeed * 1
				newVel.z = curVel.z
				ply:SetLocalVelocity(newVel)
			end
			ply.PrevSpeed = ply:GetVelocity()
			ply.PrevOnGround = ply:OnGround()
		end
	end
end

// minimum velocity to trigger function is 530
function GM:GetFallDamage( ply, vel )
	if vel > 530 then
		local minvel = vel - 530
		local dmg = math.ceil(minvel / 278 * 50)
		return dmg
	end
end