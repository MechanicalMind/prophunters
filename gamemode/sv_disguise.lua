include("sh_disguise.lua")

local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function GM:PlayerDisguise(ply)

	if ply:Team() == 3 then
		local tr = ply:GetEyeTraceNoCursor()
		if IsValid(tr.Entity) then
			if tr.HitPos:Distance(tr.StartPos) < 100 then
				if ply:CanDisguiseAsProp(tr.Entity) then
					ply:DisguiseAsProp(tr.Entity)
				end
			else
				-- ply:ChatPrint("too far " .. math.floor(tr.HitPos:Distance(tr.StartPos)))
			end
		end
	end
end

function PlayerMeta:DisguiseAsProp(ent)

	local hullxy, hullz = ent:GetPropSize()
	if !self:CanFitHull(hullxy, hullz) then
		local ct = ChatText()
		ct:Add("Not enough room to disguise as that, move into a more open area", Color(255, 50, 50))
		ct:Send(self)
		return
	end
	
	if !self:IsDisguised() then
		self.OldPlayerModel = self:GetModel()
	end
	self:SetNWBool("disguised", true)
	self:SetNWString("disguiseModel", ent:GetModel())
	self:SetNWVector("disguiseMins", ent:OBBMins())
	self:SetNWVector("disguiseMaxs", ent:OBBMaxs())
	self:SetColor(Color(255, 0, 0, 0))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetModel(ent:GetModel())
	self:SetNoDraw(false)
	self:DrawShadow(false)
	GAMEMODE:PlayerSetNewHull(self, hullxy, hullz, hullz)
	self:EmitSound("weapons/bugbait/bugbait_squeeze" .. math.random(1, 3) .. ".wav")
end

function PlayerMeta:IsDisguised()
	return self:GetNWBool("disguised", false)
end

function PlayerMeta:UnDisguise()
	self:SetNWBool("disguised", false)
	self:SetColor(Color(255, 255, 255, 255))
	self:SetNoDraw(false)
	self:DrawShadow(true)
	self:SetRenderMode( RENDERMODE_NORMAL)
	GAMEMODE:PlayerSetNewHull(self)
	if self.OldPlayerModel then
		self:SetModel(self.OldPlayerModel)
	end
end