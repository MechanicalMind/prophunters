
local categories = {}

local function addHelpText(heading, size, text, color)

	local t = {}
	t.heading = heading
	t.size = size or 1
	t.category = cat
	t.text = text
	t.color = color 
	table.insert(categories, t)
end


addHelpText("Intro", 1, [[
Prop Hunters is a gamemode based on the classic Prop Hunt. I've added better looks, more features and lots of fixes to gameplay.


==CONTROLS==
LEFT CLICK - Disguises as the prop you are looking at
C - Locks your prop's rotation when disguised
F3 - Taunt

==OBJECTIVES==
The aim of the hunters is to find and kill all the props.
The aim of the props is to hide from the hunters and not get killed.
]])

local function colMul(color, mul)
	color.r = math.Clamp(math.Round(color.r * mul), 0, 255)
	color.g = math.Clamp(math.Round(color.g * mul), 0, 255)
	color.b = math.Clamp(math.Round(color.b * mul), 0, 255)
end

local menu
local function openHelpScreen()
	if IsValid(menu) then
		menu:SetVisible(!menu:IsVisible())
	else
		menu = vgui.Create("DFrame")
		GAMEMODE.ScoreboardPanel = menu
		menu:SetSize(ScrW() * 0.8, ScrH() * 0.8)
		menu:Center()
		menu:MakePopup()
		menu:SetKeyboardInputEnabled(false)
		menu:SetDeleteOnClose(false)
		menu:SetDraggable(false)
		menu:ShowCloseButton(true)
		menu:SetTitle("")
		-- menu:DockPadding(0, 0, 0, 0)
		menu:DockPadding(8, 8 + draw.GetFontHeight("RobotoHUD-25"), 8, 8)
		function menu:PerformLayout()
		end

		function menu:Paint(w, h)
			surface.SetDrawColor(40,40,40,230)
			surface.DrawRect(0, 0, w, h)

			surface.SetFont("RobotoHUD-25")
			local t = "Help"
			local tw,th = surface.GetTextSize(t)
			draw.ShadowText(t, "RobotoHUD-25", 8, 2, Color(132, 199, 29), 0)

			draw.ShadowText("learn about the gamemode", "RobotoHUD-L15", 8 + tw + 16, 2 + th * 0.90, Color(220, 220, 220), 0, 4)
		end

		local catlist = vgui.Create("DScrollPanel", menu)
		catlist:Dock(LEFT)
		catlist:SetWide(200)
		function catlist:Paint(w, h)
		end

		// child positioning
		local canvas = catlist:GetCanvas()
		canvas:DockPadding(0, 0, 0, 0)
		function canvas:OnChildAdded( child )
			child:Dock( TOP )
			child:DockMargin( 0,0,0,4 )
		end

		for k, t in pairs(categories) do
			local font = "RobotoHUD-20"
			if t.size == 2 then
				font = "RobotoHUD-15"
			end
			local but = vgui.Create("DButton")
			but:SetText("")
			but:SetTall(draw.GetFontHeight(font) * 1.2)
			but.Selected = false
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

				draw.ShadowText(t.heading, font, w / 2, h / 2, colt, 1, 1)
			end
			function but:DoClick()
				menu.TextContent.Text = t.text
				menu.TextContent:InvalidateLayout()
			end
			catlist:AddItem(but)
		end


		local textscroll = vgui.Create("DScrollPanel", menu)
		textscroll:Dock(FILL)
		function textscroll:Paint(w, h)
			surface.SetDrawColor(68, 68, 68, 160)
			surface.DrawOutlinedRect(0, 0, w, h)

			surface.SetDrawColor(55, 55, 55, 120)
			surface.DrawRect(1, 1, w - 2, h - 2)
		end

		// child positioning
		local canvas = textscroll:GetCanvas()
		canvas:DockPadding(0, 0, 0, 0)
		function canvas:OnChildAdded( child )
			child:Dock( TOP )
			child:DockMargin( 0,0,0,4 )
		end

		local pnl = vgui.Create("DPanel")
		menu.TextContent = pnl
		pnl:SetWide(400)
		pnl.Text = categories[1].text
		catlist:GetCanvas():GetChildren()[1].Selected = true
		textscroll:AddItem(pnl)
		function pnl:PerformLayout()
			if self.Text then
				self.TextLines = WrapText("RobotoHUD-L15", self:GetWide() - 16, {self.Text})
			end
			if self.TextLines then
				local y = self.TextLines.height
				self:SetTall(y + 8)
			end
		end

		function pnl:Paint(w, h)
			-- surface.SetDrawColor(0, 0, 0, 255)
			-- surface.DrawOutlinedRect(0, 0, w, h)
			if self.TextLines then
				self.TextLines:Paint(8, 4)
			end
		end
	end
end
concommand.Add("mb_helpscreen", openHelpScreen)
net.Receive("mb_openhelpmenu", openHelpScreen)