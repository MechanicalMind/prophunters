GM.BannedModels = {}

function GM:IsModelBanned(model)
	return table.HasValue(self.BannedModels, model)
end

function GM:AddBannedModel(model)
	table.insert(self.BannedModels, model)
end

function GM:RemoveBannedModel(model)
	table.RemoveByValue(self.BannedModels, model)
end

function GM:GetBannedModels()
	return self.BannedModels
end

net.Receive("ph_bannedmodels", function (len)
	GAMEMODE.BannedModels = {}

	while true do
		local k = net.ReadUInt(16)
		if k == 0 then
			break
		end
		local v = net.ReadString()
		GAMEMODE.BannedModels[k] = v
	end
end)

local menu
concommand.Add("ph_bannedmodels_menu", function (client)
	if !client:IsSuperAdmin() then
		if IsValid(menu) then
			menu:Remove()
		end
		return
	end
	if IsValid(menu) then
		menu:SetVisible(true)
		net.Start("ph_bannedmodels")
		net.SendToServer()
		return
	end

	-- GAMEMODE.BannedModels = {"asd/models.ad"}

	menu = vgui.Create("DFrame")
	menu:SetSize(ScrW() * 0.4, ScrH() * 0.8)
	menu:SetTitle("Banned Models")
	menu:Center()
	menu:MakePopup()

	local mlist = vgui.Create("DScrollPanel", menu)
	mlist:Dock(FILL)

	local canvas = mlist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock(TOP)
	end

	local but = vgui.Create("DButton")
	but:SetText("")
	but:Dock(TOP)

	function but:PerformLayout()
		local c = 0
		for k, v in pairs(GAMEMODE.BannedModels) do
			c = c + 1
		end
		c = c + 2
		self:SetTall(c * 20 + 8)
	end

	local icon = Material("icon16/cross.png")
	function but:Paint(w, h)
		-- surface.SetDrawColor(50, 50, 50)
		-- surface.DrawRect(0, 0, w, h)

		surface.SetMaterial(icon)

		local mx, my = gui.MousePos()
		local sx, sy = self:LocalToScreen(0, 0)
		local s
		if mx >= sx + w - 16 - 4 && mx < sx + w - 4 then
			sx = mx - sx - 4
			sy = my - sy - 4
			s = math.floor(sy / 20)
		end

		local c = 0
		for k, v in pairs(GAMEMODE.BannedModels) do

			draw.SimpleText(v, "RobotoHUD-L15", 4, 4 + c * 20, color_white, 0)
			if s == c then
				surface.SetDrawColor(50, 50, 50)
			else
				surface.SetDrawColor(255, 255, 255)
			end
			surface.DrawTexturedRect(w - 16 - 4, c * 20 + 6, 16, 16)

			c = c + 1
		end
	end

	function but:DoClick()
		local w, h = self:GetSize()

		local mx, my = gui.MousePos()
		local sx, sy = self:LocalToScreen(0, 0)
		local s
		if mx >= sx + w - 16 - 4 && mx < sx + w - 4 then
			sx = mx - sx - 4
			sy = my - sy - 4
			s = math.floor(sy / 20)
		end

		local c = 0
		for k, v in pairs(GAMEMODE.BannedModels) do
			if s == c then
				RunConsoleCommand("ph_bannedmodels_remove", v)
				net.Start("ph_bannedmodels")
				net.SendToServer()
				break
			end
			c = c + 1
		end
	end

	mlist:AddItem(but)
	mlist:InvalidateLayout()

	local entry = vgui.Create("DTextEntry", menu)
	entry:Dock(BOTTOM)

	function entry:OnEnter()
		RunConsoleCommand("ph_bannedmodels_add", entry:GetValue())
		entry:SetText("")
		net.Start("ph_bannedmodels")
		net.SendToServer()
	end

	net.Start("ph_bannedmodels")
	net.SendToServer()
end)