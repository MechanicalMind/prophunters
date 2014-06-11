GM.BannedModels = {}

util.AddNetworkString("ph_bannedmodels")

function GM:IsModelBanned(model)
	return table.HasValue(self.BannedModels, model)
end

function GM:AddBannedModel(model)
	table.insert(self.BannedModels, model)
	self:SaveBannedModels()
	self:RemoveBannedModelProps()
end

function GM:RemoveBannedModel(model)
	table.RemoveByValue(self.BannedModels, model)
	self:SaveBannedModels()
end

function GM:GetBannedModels()
	return self.BannedModels
end

function GM:SaveBannedModels()
	// ensure the folders are there
	if !file.Exists("prophunters/","DATA") then
		file.CreateDir("prophunters")
	end

	local txt = ""
	for k, v in pairs(self.BannedModels) do
		txt = txt .. v .. "\r\n"
	end
	file.Write("prophunters/bannedmodels.txt", txt)
end

function GM:LoadBannedModels() 
	local jason = file.ReadDataAndContent("prophunters/bannedmodels.txt")
	if jason then
		local tbl = {}
		for map in jason:gmatch("[^\r\n]+") do
			table.insert(tbl, map)
		end
		self.BannedModels = tbl
	else

		// don't touch this
		// use ph_bannedmodels_menu or edit data/prophunters/bannedmodels.txt
		self.BannedModels = {
			"models/props/cs_assault/money.mdl",
			"models/props/cs_office/computer_mouse.mdl",
			"models/props/cs_office/projector_remote.mdl"
		}
	end
end

function GM:RemoveBannedModelProps()
	for k, ent in pairs(ents.GetAll()) do
		if IsValid(ent) && ent:IsDisguisableAs() then
			if self:IsModelBanned(ent:GetModel()) then
				ent:Remove()
			end
		end
	end
end

net.Receive("ph_bannedmodels", function (len, ply)
	if ply.BannedAntiSpam && ply.BannedAntiSpam > CurTime() then return end
	ply.BannedAntiSpam = CurTime() + 0.1

	net.Start("ph_bannedmodels")
	for k, v in pairs(GAMEMODE.BannedModels) do
		net.WriteUInt(k, 16)
		net.WriteString(tostring(v))
	end
	net.WriteUInt(0, 16)
	net.Send(ply)
end)

concommand.Add("ph_bannedmodels_add", function (ply, com, args)
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("Not a superadmin")
		return
	end
	if #args < 1 then
		ply:ChatPrint("Too few arguments")
		return
	end
	GAMEMODE:AddBannedModel(args[1])
end)

concommand.Add("ph_bannedmodels_remove", function (ply, com, args)
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("Not a superadmin")
		return
	end
	if #args < 1 then
		ply:ChatPrint("Too few arguments")
		return
	end
	GAMEMODE:RemoveBannedModel(args[1])
end)