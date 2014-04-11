
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

-- addHelpText("Melonbomber is a game where you try to elimate the other players with explosive melons while grabbing upgrades to increase your power\n\n", Color(240, 240, 240))
-- addHelpText("Based on the game Bomberman, Melonbomber brings the same hectic, fast paced gameplay to GMod. Players can place explosive melons and use them to kill other players or destroy wooden crates around the map. Inside the crates can be found powerups that can give you an edge on other players. Having more players increases the fun leading to an unstopabble good time\n\n")

-- addHelpText("Powerups include\n", Color(240, 240, 240))
-- addHelpText("Speed Up", Color(0, 150, 255))
-- addHelpText(" - increases your running speed\n")
-- addHelpText("Bomb Up", Color(50,255,50))
-- addHelpText(" - increases the max bombs you can place at a time\n")
-- addHelpText("Power Up", Color(220,50,50))
-- addHelpText(" - increase the length of your bomb's explosions\n")
-- addHelpText("Bomb Kick", Color(250, 100, 0))
-- addHelpText(" - the power to move around bombs\n")
-- addHelpText("Power Bomb", Color(155, 20, 80))
-- addHelpText(" - a incredibly powerful mega bomb\n")
-- addHelpText("Remote Control", Color(220, 190, 0))
-- addHelpText(" - the ability to remotely detonate your bombs\n")
-- addHelpText("Piercing", Color(0, 70, 220))
-- addHelpText(" - bomb explosions pass through breakable crates\n")
-- addHelpText("Line Bomb", Color(150, 0, 180))
-- addHelpText(" - place a line of bombs with right click\n")

addHelpText("Intro", 1, [[
Melonbomber is a game where you try to elimate the other players with explosive melons while grabbing upgrades to increase your power


Based on the game Bomberman, Melonbomber brings the same hectic, fast paced gameplay to GMod. Players can place explosive melons and use them to kill other players or destroy wooden crates around the map. Inside the crates can be found powerups that can give you an edge on other players.

==CONTROLS==
WASD to move around
LEFT CLICK to place a bomb

==OBJECTIVES==
The aim of the game is to take out the other players by blowing them up with your bombs
]])

addHelpText("Powerups", 1, [[
Powerups can be found inside crates on the map. Blow up the crates to reveal powerups. Walk over the powerup to pick it up.
]])

addHelpText("Speed Up", 2, "")

local function wrapText(font, maxWidth, txt)
	surface.SetFont(font)
	local sw, sh = surface.GetTextSize(" ")
	local lines = {}
	// add a new line because it ignore the last line
	for chunk in (txt .. "\n"):gmatch("([^\n]-)\n") do
		local curWidth = 0
		local curText
		for word in chunk:gmatch("[^%s]+") do
			local w, h = surface.GetTextSize(word)

			// can't we fit the word on the same line
			if w + sw + curWidth > maxWidth then

				// is the word too long for a single line (then we need to split it)
				if w + sw > maxWidth then
					curWidth = curWidth + sw
					curText = curText .. " "

					// while our current word cannot fit in the line
					while curWidth + w > maxWidth do

						// find the number of chracters that can fit
						local chars = 1
						while true do
							local aw, ah = surface.GetTextSize(word:sub(1, chars))
							if chars > #word then
								print('error' .. chars)
								break
							end
							if aw + curWidth > maxWidth then
								chars = chars - 1
								break
							end
							chars = chars + 1
						end

						// add the partial word to line
						local line = {}
						line.text = curText .. word:sub(1, chars)
						table.insert(lines, line)

						// start a new line with the rest of the characters
						curWidth = 0
						curText = ""

						word = word:sub(chars + 1)
						w, h = surface.GetTextSize(word)
					end

					curWidth = w
					curText = word
				else
					// put the word on a new line
					local line = {}
					line.text = curText or ""
					table.insert(lines, line)

					curWidth = w
					curText = word
				end
			else
				// add the word to the current line
				if curText then
					curText = curText .. " " .. word
				else
					curText = word
				end
				curWidth = curWidth + sw + w
			end
		end
		if curText then
			local line = {}
			line.text = curText
			table.insert(lines, line)
		elseif #chunk == 0 then
			table.insert(lines, {text = ""})
		end
	end
	return lines
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
			surface.SetDrawColor(130, 130, 130, 255)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(80, 80, 80, 255)
			surface.DrawOutlinedRect(0, 0, w, h)

			surface.SetFont("RobotoHUD-25")
			local t = "Help"
			local tw,th = surface.GetTextSize(t)
			draw.ShadowText(t, "RobotoHUD-25", 8, 2, Color(132, 199, 29), 0)

			draw.ShadowText("learn to blow up your enemies better", "RobotoHUD-15", 8 + tw + 16, 2 + th * 0.90, Color(220, 220, 220), 0, 4)
		end

		local catlist = vgui.Create("DScrollPanel", menu)
		catlist:Dock(LEFT)
		catlist:SetWide(200)
		function catlist:Paint(w, h)
			surface.SetDrawColor(150, 150, 150, 255)
			surface.DrawRect(0, 0, w, h)
		end

		// child positioning
		local canvas = catlist:GetCanvas()
		canvas:DockPadding(0, 0, 0, 0)
		function canvas:OnChildAdded( child )
			child:Dock( TOP )
			child:DockMargin( 0,0,0,4 )
		end

		for k, v in pairs(categories) do
			local font = "RobotoHUD-25"
			if v.size == 2 then
				font = "RobotoHUD-15"
			end
			local but = vgui.Create("DButton")
			but:SetText("")
			but:SetTall(draw.GetFontHeight(font))
			function but:Paint(w, h)
				if self.Hovered then
					surface.SetDrawColor(90, 90, 90, 255)
					surface.DrawRect(0, 0, w, h)
				end
				local col = color_white
				if self:IsDown() then
					col = Color(150, 150, 150)
				end
				draw.SimpleText(v.heading, font, w / 2, h / 2, col, 1, 1)
			end
			function but:DoClick()
				menu.TextContent.Text = v.text
				menu.TextContent:InvalidateLayout()
			end
			catlist:AddItem(but)
		end


		local textscroll = vgui.Create("DScrollPanel", menu)
		textscroll:Dock(FILL)
		function textscroll:Paint(w, h)
			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawRect(0, 0, w, h)
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
		textscroll:AddItem(pnl)
		function pnl:PerformLayout()
			if self.Text then
				self.TextLines = wrapText("RobotoHUD-15", self:GetWide() - 16, self.Text)
			end
			if self.TextLines then
				local y = #self.TextLines * draw.GetFontHeight("RobotoHUD-15")
				self:SetTall(y + 8)
			end
		end

		function pnl:Paint(w, h)
			-- surface.SetDrawColor(0, 0, 0, 255)
			-- surface.DrawOutlinedRect(0, 0, w, h)
			if self.TextLines then
				local y = 4
				for k, line in pairs(self.TextLines) do
					draw.DrawText(line.text, "RobotoHUD-15", 8, y, color_white, 0)
					y = y + draw.GetFontHeight("RobotoHUD-15")
				end
			end
		end
	end
end
concommand.Add("mb_helpscreen", openHelpScreen)
net.Receive("mb_openhelpmenu", openHelpScreen)