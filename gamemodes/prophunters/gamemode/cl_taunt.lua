
include("sh_taunt.lua")

local menu

local gradU = surface.GetTextureID("gui/gradient_up")
local gradD = surface.GetTextureID("gui/gradient_down")

local function colMul(color, mul)
	color.r = math.Clamp(math.Round(color.r * mul), 0, 255)
	color.g = math.Clamp(math.Round(color.g * mul), 0, 255)
	color.b = math.Clamp(math.Round(color.b * mul), 0, 255)
end

local function fillList(mlist, taunts, cat)
	menu.CurrentTaunts = taunts
	menu.CurrentTauntCat = cat
	for k, v in pairs(menu.CatList:GetCanvas():GetChildren()) do
		v.Selected = false
		if v.CatName == cat then
			v.Selected = true
		end
	end
	mlist:Clear()
	for k, t in pairs(taunts) do
		if t.sex && t.sex != GAMEMODE.PlayerModelSex then
			continue
		end
		if t.team && LocalPlayer():Team() != t.team then
			continue
		end
		local but = vgui.Create("DButton")
		but:SetTall(draw.GetFontHeight("RobotoHUD-L15") * 1.0)
		but:SetText("")
		function but:Paint(w, h)
			local col = Color(255, 255, 255)
			if self:IsDown() then
				colMul(col, 0.5)
			elseif self:IsHovered() then
				colMul(col, 0.8)
			end
			draw.ShadowText(t.name, "RobotoHUD-L15", 0, h / 2, col, 0, 1)
			draw.ShadowText(math.Round(t.soundDuration * 10) / 10 .. "s", "RobotoHUD-L10", w, h / 2, col, 2, 1)
		end
		function but:DoClick()
			RunConsoleCommand("ph_taunt", t.sound[math.random(#t.sound)])
			menu:Close()
		end
		mlist:AddItem(but)
	end
end

local function addCat(clist, name, taunts, mlist)
	local z = tonumber(util.CRC(name):sub(1, 8))
	local dname = name:lower():gsub("[_]", " ")
	dname = dname:sub(1, 1):upper() .. dname:sub(2)

	local but = vgui.Create("DButton")
	but:SetTall(draw.GetFontHeight("RobotoHUD-15") * 1.3)
	but:SetText("")
	but.Selected = false
	but.CatName = name
	function but:Paint(w, h)
		local col = Color(68, 68, 68, 160)
		local colt = Color(190, 190, 190)
		if !self.Selected then
			colMul(col, 0.7)
			if self:IsDown() then
				colMul(colt, 0.5)
			elseif self:IsHovered() then
				colMul(colt, 1.2)
			end
		else
			colMul(colt, 1.2)
		end

		draw.RoundedBoxEx(4, 0, 0, w, h, col, true, false, true, false)

		draw.ShadowText(dname, "RobotoHUD-15", w / 2, h / 2, colt, 1, 1)
	end
	function but:DoClick()
		fillList(mlist, taunts, name)
		self.Selected = true
	end
	clist:AddItem(but)
	return but
end

local function fillCats(clist, mlist)
	clist:Clear()
	local all = addCat(clist, "all", Taunts, mlist)
	for k, taunts in pairs(TauntCategories) do
		local c = 0
		for a, t in pairs(taunts) do
			if t.team && LocalPlayer():Team() != t.team then
				continue
			end
			c = c + 1
		end
		if c > 0 then
			addCat(clist, k, taunts, mlist)
		end
	end
	all.Selected = true
end

local function openTauntMenu()
	if IsValid(menu) then
		fillCats(menu.CatList, menu.TauntList)
		fillList(menu.TauntList, menu.CurrentTaunts, menu.CurrentTauntCat)
		menu:SetVisible(!menu:IsVisible())
		return
	end

	menu = vgui.Create("DFrame")
	menu:SetSize(ScrW() * 0.4, ScrH() * 0.8)
	menu:Center()
	menu:SetTitle("")
	menu:MakePopup()
	menu:SetKeyboardInputEnabled(false)
	menu:SetDeleteOnClose(false)
	menu:SetDraggable(false)
	menu:ShowCloseButton(true)
	menu:DockPadding(8, 8 + draw.GetFontHeight("RobotoHUD-25"), 8, 8)

	function menu:Paint(w, h)
		surface.SetDrawColor(40,40,40,230)
		surface.DrawRect(0, 0, w, h)

		-- draw.ShadowText("Taunts", "RobotoHUD-15", 8, 4, color_white, 0)
		surface.SetFont("RobotoHUD-25")
		local t = "Taunts"
		local tw,th = surface.GetTextSize(t)
		draw.ShadowText(t, "RobotoHUD-25", 8, 2, Color(49, 142, 219), 0)

		draw.ShadowText("make annoying fart sounds", "RobotoHUD-L15", 8 + tw + 16, 2 + th * 0.90, Color(220, 220, 220), 0, 4)
	end

	local leftpnl = vgui.Create("DPanel", menu)
	leftpnl:Dock(LEFT)
	leftpnl:DockMargin(0, 0, 0, 0)
	leftpnl:SetWide(menu:GetWide() * 0.3)
	function leftpnl:Paint(w, h)
	end

	local but = vgui.Create("DButton", leftpnl)
	but:Dock(BOTTOM)
	but:DockMargin(0, 4, 4, 0)
	but:SetTall(draw.GetFontHeight("RobotoHUD-15") * 1.3)
	but:SetText("")
	function but:Paint(w, h)
		local col = Color(68, 68, 68, 160)
		local colt = Color(190, 190, 190)
		if self:IsDown() then
			colMul(colt, 0.5)
		elseif self:IsHovered() then
			colMul(colt, 1.2)
		end

		draw.RoundedBoxEx(4, 0, 0, w, h, col, true, true, true, true)

		draw.ShadowText("Random", "RobotoHUD-15", w / 2, h / 2, colt, 1, 1)
	end
	function but:DoClick()
		RunConsoleCommand("ph_taunt_random")
		menu:Close()
	end

	local clist = vgui.Create("DScrollPanel", leftpnl)
	menu.CatList = clist
	clist:Dock(FILL)
	clist:DockMargin(0, 0, 0, 0)
	local df = draw.GetFontHeight("RobotoHUD-15") * 1.6
	function clist:Paint(w, h)
		-- surface.SetDrawColor(60, 60, 60)
		-- surface.DrawRect(0, 0, w, df)

		-- draw.SimpleText("Categories", "RobotoHUD-15", w / 2, df / 2, color_white, 1, 1)
	end

	local canvas = clist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock( TOP )
		child:DockMargin(0, 0, 0, 4)
	end



	local mlist = vgui.Create("DScrollPanel", menu)
	menu.TauntList = mlist
	mlist:Dock(FILL)
	function mlist:Paint(w, h)
		surface.SetDrawColor(68, 68, 68, 160)
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(55, 55, 55, 120)
		surface.DrawRect(1, 1, w - 2, h - 2)
	end

	// child positioning
	local canvas = mlist:GetCanvas()
	canvas:DockPadding(8, 8, 8, 8)
	function canvas:OnChildAdded( child )
		child:Dock( TOP )
		child:DockMargin(0, 0, 0, 4)
	end

	fillList(mlist, Taunts)
	fillCats(clist, mlist, "all")
end

concommand.Add("ph_menu_taunt", openTauntMenu)
net.Receive("open_taunt_menu", openTauntMenu)