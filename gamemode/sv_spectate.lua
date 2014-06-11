util.AddNetworkString("spectating_status")

local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:CSpectate(mode, spectatee) 
	mode = mode or OBS_MODE_IN_EYE
	self:Spectate(mode)
	if IsValid(spectatee) then
		self:SpectateEntity(spectatee)
		self.Spectatee = spectatee
	else
		self.Spectatee = nil
	end
	self.SpectateMode = mode
	self.Spectating = true
	net.Start("spectating_status")
	net.WriteInt(self.SpectateMode or -1, 8)
	net.WriteEntity(self.Spectatee or Entity(-1))
	net.Send(self)
end

function PlayerMeta:UnCSpectate(mode, spectatee) 
	self:UnSpectate()
	self.SpectateMode = nil
	self.Spectatee = nil
	self.Spectating = false
	net.Start("spectating_status")
	net.WriteInt(-1, 8)
	net.WriteEntity(Entity(-1))
	net.Send(self)
end

function PlayerMeta:IsCSpectating() 
	return self.Spectating
end

function PlayerMeta:GetCSpectatee() 
	return self.Spectatee
end

function PlayerMeta:GetCSpectateMode() 
	return self.SpectateMode
end

function GM:SpectateThink()
	for k, ply in pairs(player.GetAll()) do
		if ply:IsCSpectating() && IsValid(ply:GetCSpectatee()) && (!ply.LastSpectatePosSet || ply.LastSpectatePosSet < CurTime()) then
			ply.LastSpectatePosSet = CurTime() + 0.25
			ply:SetPos(ply:GetCSpectatee():GetPos())
		end
	end
end

function GM:SpectateNext(ply, direction)
	direction = direction or 1

	local players = {}
	local index = 1
	for k, v in pairs(player.GetAll()) do
		if v != ply then
			// can only spectate same team and alive
			if v:Alive() && v:Team() == ply:Team() then
				table.insert(players, v)
				if v == ply:GetCSpectatee() then
					index = #players
				end
			end
		end
	end
	if #players > 0 then
		index = index + direction
		if index > #players then
			index = 1
		end
		if index < 1 then
			index = #players
		end

		local ent = players[index]
		if IsValid(ent) then
			ply:CSpectate(OBS_MODE_CHASE, ent)
		else
			if IsValid(ply:GetRagdollEntity()) then
				if ply:GetCSpectatee() != ply:GetRagdollEntity() then
					ply:CSpectate(OBS_MODE_CHASE, ply:GetRagdollEntity())
				end
			else
				ply:CSpectate(OBS_MODE_ROAMING)
			end
		end
	else
		if IsValid(ply:GetRagdollEntity()) then
			if ply:GetCSpectatee() != ply:GetRagdollEntity() then
				ply:CSpectate(OBS_MODE_CHASE, ply:GetRagdollEntity())
			end
		else
			ply:CSpectate(OBS_MODE_ROAMING)
		end
	end
end

function GM:ChooseSpectatee(ply) 

	if !ply.SpectateTime || ply.SpectateTime < CurTime() then

		local direction 
		if ply:KeyPressed(IN_ATTACK) || ply:KeyPressed(IN_JUMP) then
			direction = 1
		elseif ply:KeyPressed(IN_ATTACK2) || ply:KeyPressed(IN_DUCK) then
			direction = -1
		end

		if direction then
			self:SpectateNext(ply, direction)
		end
	end

	// if invalid or dead
	if !IsValid(ply:GetCSpectatee()) then
		self:SpectateNext(ply)
	end
end