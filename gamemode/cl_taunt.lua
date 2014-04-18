
include("sh_taunt.lua")

local menu

local gradU = surface.GetTextureID("gui/gradient_up")
local gradD = surface.GetTextureID("gui/gradient_down")

local function fillList(mlist, taunts)
	mlist:Clear()
	for k, t in pairs(taunts) do
		local but = vgui.Create("DButton")
		but:SetTall(draw.GetFontHeight("RobotoHUD-15") * 1.4)
		but:SetText("")
		function but:Paint(w, h)
			surface.SetDrawColor(t.color)
			surface.DrawRect(0, 0, w, h)
		
			if self:IsDown() then
				surface.SetDrawColor(60, 60, 60, 50)
				surface.DrawRect(0, 0, w, h)
			elseif self:IsHovered() then
				surface.SetDrawColor(230, 230, 230, 50)
				surface.DrawRect(0, 0, w, h)
			else
			end

			draw.ShadowText(t.name, "RobotoHUD-15", w / 2, h / 2, color_white, 1, 1)
			draw.ShadowText(math.Round(t.soundDuration * 10) / 10 .. "s", "RobotoHUD-10", w - 4, h / 2, color_white, 2, 1)
		end
		function but:DoClick()
			RunConsoleCommand("ph_taunt", t.sound[math.random(#t.sound)])
		end
		mlist:AddItem(but)
	end
end

local function addCat(clist, name, taunts, mlist)
	local z = tonumber(util.CRC(name):sub(1, 8))
	local color = Color(z % 255, math.floor(z / 255) % 255, math.floor(z / 255 / 255) % 255)
	color = Color(150, 150, 150)

	local but = vgui.Create("DButton")
	but:SetTall(draw.GetFontHeight("RobotoHUD-15") * 1.4)
	but:SetText("")
	function but:Paint(w, h)
		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, w, h)
	
		if self:IsDown() then
			surface.SetDrawColor(60, 60, 60, 50)
			surface.DrawRect(0, 0, w, h)
		elseif self:IsHovered() then
			surface.SetDrawColor(230, 230, 230, 50)
			surface.DrawRect(0, 0, w, h)
		else
		end

		draw.ShadowText(name, "RobotoHUD-15", w / 2, h / 2, color_white, 1, 1)
	end
	function but:DoClick()
		fillList(mlist, taunts)
	end
	clist:AddItem(but)
end

concommand.Add("ph_menu_taunt", function ()
	if IsValid(menu) then
		menu:Remove()
	end

	menu = vgui.Create("DFrame")
	menu:SetSize(ScrW() * 0.5, ScrH() * 0.8)
	menu:Center()
	menu:SetTitle("")
	menu:MakePopup()
	menu:SetKeyboardInputEnabled(false)
	menu:SetDeleteOnClose(true)
	menu:SetDraggable(false)
	menu:ShowCloseButton(true)

	function menu:Paint(w, h)
		surface.SetDrawColor(120, 120, 120)
		surface.DrawRect(0, 0, w, h)

		draw.ShadowText("Taunts", "RobotoHUD-15", 8, 4, color_white, 0)
	end

	local clist = vgui.Create("DScrollPanel", menu)
	clist:Dock(LEFT)
	clist:SetWide(menu:GetWide() * 0.4)
	clist:DockMargin(0, 0, 4, 0)
	function clist:Paint(w, h)
		surface.SetDrawColor(50, 50, 50)
		surface.DrawRect(0, 0, w, h)
	end

	// child positioning
	local canvas = clist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock( TOP )
		child:DockMargin( 0,0,0,4 )
	end



	local mlist = vgui.Create("DScrollPanel", menu)
	mlist:Dock(FILL)
	function mlist:Paint(w, h)
		surface.SetDrawColor(50, 50, 50)
		surface.DrawRect(0, 0, w, h)
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
end)