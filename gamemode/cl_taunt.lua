
include("sh_taunt.lua")

local menu

local gradU = surface.GetTextureID("gui/gradient_up")
local gradD = surface.GetTextureID("gui/gradient_down")

local function colMul(color, mul)
	color.r = math.Clamp(math.Round(color.r * mul), 0, 255)
	color.g = math.Clamp(math.Round(color.g * mul), 0, 255)
	color.b = math.Clamp(math.Round(color.b * mul), 0, 255)
end

local function fillList(mlist, taunts)
	menu.CurrentTaunts = taunts
	mlist:Clear()
	for k, t in pairs(taunts) do
		if t.sex && t.sex != GAMEMODE.PlayerModelSex then
			continue
		end
		local but = vgui.Create("DButton")
		but:SetTall(draw.GetFontHeight("RobotoHUD-15") * 1.4)
		but:SetText("")
		function but:Paint(w, h)
			local col = Color(150, 150, 150)
			if self:IsDown() then
				colMul(col, 0.5)
			elseif self:IsHovered() then
				colMul(col, 1.2)
			end
			draw.RoundedBox(4, 0, 0, w, h, col)
		

			draw.ShadowText(t.name, "RobotoHUD-15", 4, h / 2, Color(230, 230, 230), 0, 1)
			draw.ShadowText(math.Round(t.soundDuration * 10) / 10 .. "s", "RobotoHUD-10", w - 4, h / 2, color_white, 2, 1)
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

	local but = vgui.Create("DButton")
	but:SetTall(draw.GetFontHeight("RobotoHUD-10") * 1.6)
	but:SetText("")
	function but:Paint(w, h)
		local col = Color(150, 150, 150)
		if self:IsDown() then
			colMul(col, 0.5)
		elseif self:IsHovered() then
			colMul(col, 1.2)
		end
		surface.SetDrawColor(col)
		surface.DrawRect(0, 0, w, h)


		draw.SimpleText(name, "RobotoHUD-10", w / 2, h / 2, Color(50, 50, 50), 1, 1)
	end
	function but:DoClick()
		fillList(mlist, taunts)
	end
	clist:AddItem(but)
end

local function openTauntMenu()
	if LocalPlayer():Team() != 3 then
		if IsValid(menu) then
			menu:SetVisible(false)
		end
		return
	end
	if IsValid(menu) then
		fillList(menu.TauntList, menu.CurrentTaunts)
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
		surface.SetDrawColor(120, 120, 120)
		surface.DrawRect(0, 0, w, h)

		-- draw.ShadowText("Taunts", "RobotoHUD-15", 8, 4, color_white, 0)
		surface.SetFont("RobotoHUD-25")
		local t = "Taunts"
		local tw,th = surface.GetTextSize(t)
		draw.ShadowText(t, "RobotoHUD-25", 8, 2, Color(49, 142, 219), 0)

		draw.ShadowText("make annoying fart sounds", "RobotoHUD-15", 8 + tw + 16, 2 + th * 0.90, Color(220, 220, 220), 0, 4)
	end

	local clist = vgui.Create("DScrollPanel", menu)
	clist:Dock(LEFT)
	clist:SetWide(menu:GetWide() * 0.3)
	clist:DockMargin(0, 0, 4, 0)
	local df = draw.GetFontHeight("RobotoHUD-15") * 1.6
	function clist:Paint(w, h)
		surface.SetDrawColor(60, 60, 60)
		surface.DrawRect(0, 0, w, df)

		draw.SimpleText("Categories", "RobotoHUD-15", w / 2, df / 2, color_white, 1, 1)
	end

	// child positioning
	local canvas = clist:GetCanvas()
	canvas:DockPadding(3, df, 3, 3)
	function canvas:OnChildAdded( child )
		child:Dock( TOP )
		child:DockMargin(0, 0, 0, 1)
	end



	local mlist = vgui.Create("DScrollPanel", menu)
	menu.TauntList = mlist
	mlist:Dock(FILL)
	function mlist:Paint(w, h)
		surface.SetDrawColor(50, 50, 50)
		-- surface.DrawRect(0, 0, w, h)
	end

	// child positioning
	local canvas = mlist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock( TOP )
		child:DockMargin( 0,0,0,4 )
	end

	addCat(clist, "All", Taunts, mlist)
	for k, v in pairs(TauntCategories) do
		addCat(clist, k, v, mlist)
	end

	fillList(mlist, Taunts)
end

concommand.Add("ph_menu_taunt", openTauntMenu)
net.Receive("open_taunt_menu", openTauntMenu)