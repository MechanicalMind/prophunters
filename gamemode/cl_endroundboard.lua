if GAMEMODE && IsValid(GAMEMODE.EndRoundPanel) then
	GAMEMODE.EndRoundPanel:Remove()
end

local menu

local muted = Material("icon32/muted.png")
local unmuted = Material("icon32/unmuted.png")

local function addPlayerItem(self, mlist, ply)

	local but = vgui.Create("DButton")
	but.player = ply
	but.ctime = CurTime()
	but:SetTall(draw.GetFontHeight("RobotoHUD-20") + 4)
	but:SetText("")

	function but:Paint(w, h)

		surface.SetDrawColor(color_black)
		-- surface.DrawOutlinedRect(0, 0, w, h)

		if IsValid(ply) && ply:IsPlayer() then
			local col = team.GetColor(ply:Team())
			if self.Hovered then
				surface.SetDrawColor(col.r, col.g, col.b, 20)
				surface.DrawRect(0, 0, w, h)
			end
			local s = 4

			if ply:IsSpeaking() then
				surface.SetMaterial(unmuted)

				local v = ply:VoiceVolume()

				local x, y = self:LocalToScreen(0, 0)
				render.SetScissorRect(x, y, x + s + 32 * (0.5 + v / 2), y + h, true)

				// draw mute icon
				surface.SetDrawColor(255, 255, 255, 255)
				-- surface.SetDrawColor(255, 255, 255, 255 * math.Clamp(v, 0.1, 1))
				surface.DrawTexturedRect(s, h / 2 - 16, 32, 32)
				s = s + 32 + 4

				render.SetScissorRect(0, 0, 0, 0, false)
			end

			if ply:IsMuted() then
				surface.SetMaterial(muted)

				// draw mute icon
				surface.SetDrawColor(150, 150, 150, 255)
				surface.DrawTexturedRect(s, h / 2 - 16, 32, 32)
				s = s + 32 + 4
			end

			draw.SimpleText(ply:Ping(), "RobotoHUD-20", w - 4, 0, col, 2)

			draw.SimpleText(ply:Nick(), "RobotoHUD-20", s, 0, col, 0)
		end
	end

	function but:DoClick()
		if IsValid(ply) then
			GAMEMODE:DoScoreboardActionPopup(ply)
		end
	end

	mlist:AddItem(but)
end

local function doPlayerItems(self, mlist)

	local add = false
	for k, ply in pairs(player.GetAll()) do
		local found = false

		for t,v in pairs(mlist:GetCanvas():GetChildren()) do
			if v.player == ply then
				found = true
				v.ctime = CurTime()
			end
		end

		if !found then
			addPlayerItem(self, mlist, ply)
			add = true
		end
	end
	local del = false

	for t,v in pairs(mlist:GetCanvas():GetChildren()) do
		if !v.perm && v.ctime != CurTime() then
			v:Remove()
			del = true
		end
	end
	// make sure the rest of the elements are sorted and moved up to fill gaps
	if del || add then
		timer.Simple(0, function() 
			local childs = mlist:GetCanvas():GetChildren()
			table.sort(childs, function (a, b)
				if !IsValid(a) then print(a, b, 1) return false end
				if !IsValid(b) then print(a, b, 2) return false end
				if !IsValid(a.player) then print(a, b, 3) return false end
				if !IsValid(b.player) then print(a, b, 4) return false end
				return a.player:Team() * 1000 + a.player:EntIndex() < b.player:Team() * 1000 + b.player:EntIndex()
			end)
			
			for k, v in pairs(childs) do
				v:SetParent(mlist)
			end
			mlist:GetCanvas():InvalidateLayout() 
		end)
	end
end

concommand.Add("ph_endroundmenu_close", function ()
	if IsValid(menu) then
		menu:Close()
	end
end)

function GM:OpenEndRoundMenu()
	chat.Close()
	if IsValid(menu) then
		menu.ChatTextEntry:SetText("")
		menu:SetVisible(true)
		return
	end

	menu = vgui.Create("DFrame")
	menu:ParentToHUD()
	GAMEMODE.EndRoundPanel = menu
	menu:SetSize(ScrW() * 0.95, ScrH() * 0.95)
	menu:Center()
	menu:SetTitle("")
	menu:MakePopup()
	menu:SetKeyboardInputEnabled(false)
	menu:SetDeleteOnClose(false)
	menu:SetDraggable(false)
	menu:ShowCloseButton(false)
	menu:DockPadding(8, 8, 8, 8)

	local matBlurScreen = Material( "pp/blurscreen" )
	function menu:Paint(w, h)
		DisableClipping(true)

		local x, y = self:LocalToScreen( 0, 0 )

		local Fraction = 0.4

		surface.SetMaterial( matBlurScreen )	
		surface.SetDrawColor( 255, 255, 255, 255 )

		for i=0.33, 1, 0.33 do
			matBlurScreen:SetFloat( "$blur", Fraction * 5 * i )
			matBlurScreen:Recompute()
			if ( render ) then render.UpdateScreenEffectTexture() end
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end
		
		surface.SetDrawColor(40,40,40,230)
		surface.DrawRect(-x, -y, ScrW(), ScrH())

		DisableClipping(false)
	end

	local leftpnl = vgui.Create("DPanel", menu)
	leftpnl:Dock(LEFT)
	function leftpnl:PerformLayout()
		self:SetWide(menu:GetWide() * 0.4)
	end
	function leftpnl:Paint(w, h)
	end

	// player list section
	local listpnl = vgui.Create("DPanel", leftpnl)
	listpnl:Dock(FILL)
	function listpnl:Paint(w, h)
		surface.SetDrawColor(20, 20, 20, 150)
		local t = draw.GetFontHeight("RobotoHUD-25") + 2
		surface.DrawRect(0, t, w, h - t)
	end


	local header = vgui.Create("DLabel", listpnl)
	header:Dock(TOP)
	header:SetFont("RobotoHUD-25")
	header:SetTall(draw.GetFontHeight("RobotoHUD-25"))
	header:SetText("Player List")
	header:DockMargin(4, 2, 4, 2)

	local plist = vgui.Create("DScrollPanel", listpnl)
	menu.PlayerList = plist
	plist:Dock(FILL)
	function plist:Paint(w, h)
	end

	function plist:Think()
		if !self.RefreshWait || self.RefreshWait < CurTime() then
			self.RefreshWait = CurTime() + 0.1
			doPlayerItems(self, plist)

		end
	end

	// child positioning
	local canvas = plist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock(TOP)
		child:DockMargin(0, 0, 0, 1)
	end

	// chat section
	local pnl = vgui.Create("DPanel", leftpnl)
	pnl:Dock(BOTTOM)
	pnl:DockMargin(0, 20, 0, 0)
	function pnl:PerformLayout()
		self:SetTall(leftpnl:GetTall() * 0.5)
	end

	function pnl:Paint(w, h)
		surface.SetDrawColor(20, 20, 20, 150)
		local t = draw.GetFontHeight("RobotoHUD-25") + 2
		surface.DrawRect(0, t, w, h - t)
	end

	local header = vgui.Create("DLabel", pnl)
	header:Dock(TOP)
	header:SetFont("RobotoHUD-25")
	header:SetTall(draw.GetFontHeight("RobotoHUD-25"))
	header:SetText("Chat")
	header:DockMargin(4, 2, 4, 2)


	local sayPnl = vgui.Create("DPanel", pnl)
	sayPnl:Dock(BOTTOM)
	sayPnl:DockPadding(4, 4, 4, 4)
	sayPnl:SetTall(draw.GetFontHeight("RobotoHUD-15") + 8)

	local entry = vgui.Create("DTextEntry", sayPnl)

	function sayPnl:Paint(w, h)
		if entry.Focused then
			surface.SetDrawColor(30, 20, 20, 150)
		else
			surface.SetDrawColor(20, 20, 20, 150)
		end
		surface.DrawRect(0, 0, w, h)
	end

	local say = vgui.Create("DLabel", sayPnl)
	say:Dock(LEFT)
	say:SetFont("RobotoHUD-15")
	say:SetTextColor(Color(150, 150, 150))
	say:SetText("Say:")
	say:DockMargin(4, 0, 0, 0)
	say:SizeToContentsX()

	entry:Dock(FILL)
	menu.ChatTextEntry = entry
	entry:SetFont("RobotoHUD-15")
	entry:SetTextColor(color_white)
	function entry:OnEnter(...)
		RunConsoleCommand("say", self:GetValue())
		self:SetText("")
		timer.Simple(0, function ()
			menu:SetKeyboardInputEnabled(true)
			self:RequestFocus()
		end)
	end
	local colCursor = Color(255, 0, 0)
	local colText = Color(180, 180, 180)
	function entry:Paint(w, h)
		self:DrawTextEntryText( self.Focused and color_white or colText, self.m_colHighlight, colCursor )
	end
	function entry:OnGetFocus()
		self.Focused = true
		menu:SetKeyboardInputEnabled(true)
	end
	function entry:OnLoseFocus()
		self.Focused = false
		menu:SetKeyboardInputEnabled(false)
	end


	local mlist = vgui.Create("DScrollPanel", pnl)
	menu.ChatList = mlist
	mlist:Dock(FILL)
	function mlist:Paint(w, h)
	end

	// child positioning
	local canvas = mlist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock(TOP)
		child:DockMargin(0, 0, 0, 1)
	end

	function mlist.VBar:SetUp( _barsize_, _canvassize_ )

		local oldSize = self.CanvasSize

		self.BarSize 	= _barsize_
		self.CanvasSize = math.max( _canvassize_ - _barsize_, 1 )

		self:SetEnabled( _canvassize_ > _barsize_ )

		self:InvalidateLayout()
		
		if self:GetScroll() == oldSize || (oldSize == 1 && self:GetScroll() == 0) then
			self:SetScroll(self.CanvasSize) 
		end
	end

	// results section
	local respnl = vgui.Create("DPanel", menu)
	menu.ResultsPanel = respnl
	respnl:Dock(FILL)
	respnl:DockMargin(20, 0, 0, 0)
	respnl:DockPadding(0, 0, 0, 0)
	function respnl:Paint(w, h)
		surface.SetDrawColor(20, 20, 20, 150)
		local t = draw.GetFontHeight("RobotoHUD-25") + 2
		surface.DrawRect(0, t, w, h - t)
	end

	local header = vgui.Create("DLabel", respnl)
	header:Dock(TOP)
	header:SetFont("RobotoHUD-25")
	header:SetTall(draw.GetFontHeight("RobotoHUD-25"))
	header:SetText("Results")
	header:DockMargin(4, 2, 4, 2)

	local winner = vgui.Create("DLabel", respnl)
	menu.WinningTeam = winner
	winner:Dock(TOP)
	winner:DockMargin(20, 20, 20, 20)
	winner:SetTall(draw.GetFontHeight("RobotoHUD-45"))
	winner:SetText("Props win!")
	winner:SetColor(team.GetColor(3))
	winner:SetFont("RobotoHUD-45")

	local timeleft = vgui.Create("DPanel", respnl)
	timeleft:Dock(BOTTOM)
	timeleft:SetTall(draw.GetFontHeight("RobotoHUD-20"))
	local col = Color(150, 150, 150)
	function timeleft:Paint(w, h)
		if GAMEMODE:GetGameState() == 3 then
			local settings = GAMEMODE:GetRoundSettings()
			local roundTime = settings.NextRoundTime or 30
			local time = math.max(0, roundTime - GAMEMODE:GetStateRunningTime())
			draw.SimpleText("Next round in " .. math.ceil(time), "RobotoHUD-20", w - 4, 0, col, 2)
		end
	end

	local mlist = vgui.Create("DScrollPanel", respnl)
	menu.ResultList = mlist
	mlist:Dock(FILL)
	mlist:DockMargin(20, 0, 20, 0)
	function mlist:Paint(w, h)
	end

	local canvas = mlist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock(TOP)
		child:DockMargin(0, 0, 0, 16)
	end

	// map vote
	local votepnl = vgui.Create("DPanel", menu)
	votepnl:SetVisible(false)
	menu.VotePanel = votepnl
	votepnl:Dock(FILL)
	votepnl:DockMargin(20, 0, 0, 0)
	votepnl:DockPadding(0, 0, 0, 0)
	function votepnl:Paint(w, h)
		surface.SetDrawColor(20, 20, 20, 150)
		local t = draw.GetFontHeight("RobotoHUD-25") + 2
		surface.DrawRect(0, t, w, h - t)
	end

	local header = vgui.Create("DLabel", votepnl)
	header:Dock(TOP)
	header:SetFont("RobotoHUD-25")
	header:SetTall(draw.GetFontHeight("RobotoHUD-25"))
	header:SetText("Map voting")
	header:DockMargin(4, 2, 4, 2)

	local timeleft = vgui.Create("DPanel", votepnl)
	timeleft:Dock(BOTTOM)
	timeleft:SetTall(draw.GetFontHeight("RobotoHUD-20"))
	local col = Color(150, 150, 150)
	function timeleft:Paint(w, h)
		if GAMEMODE:GetGameState() == 4 then
			local voteTime = GAMEMODE.MapVoteTime or 30
			local time = math.max(0, voteTime - GAMEMODE:GetMapVoteRunningTime())
			draw.SimpleText("Voting ends in " .. math.ceil(time), "RobotoHUD-20", w - 4, 0, col, 2)
		end
	end

	local mlist = vgui.Create("DScrollPanel", votepnl)
	menu.MapVoteList = mlist
	mlist:Dock(FILL)
	mlist:DockMargin(0, 20, 0, 20)
	function mlist:Paint(w, h)
	end

	local canvas = mlist:GetCanvas()
	canvas:DockPadding(20, 0, 20, 0)
	function canvas:OnChildAdded( child )
		child:Dock(TOP)
		child:DockMargin(0, 0, 0, 16)
	end
end

function GM:CloseEndRoundMenu()
	if IsValid(menu) then
		menu:Close()
	end
end

local awards = {
	LastPropStanding = {
		name = "Longest Survivor",
		desc = "Prop who survived longest"
	},
	LeastMovement = {
		name = "Least Movement",
		desc = "Prop who moved the least"
	},
	MostTaunts = {
		name = "Most Taunts",
		desc = "Prop who taunted the most"
	},
	FirstHunterKill = {
		name = "First Blood",
		desc = "Hunter who had the first kill"
	},
	MostKills = {
		name = "Most Kills",
		desc = "Hunter who had the most kills"
	},
	PropDamage = {
		name = "Angriest Player",
		desc = "Hunter who shot at props the most"
	},
	MostMovement = {
		name = "Most Movement",
		desc = "Prop who moved the most"
	}
}

function GM:EndRoundMenuResults(res)
	self:OpenEndRoundMenu()
	menu.ResultsPanel:SetVisible(true)
	menu.VotePanel:SetVisible(false)

	menu.Results = res
	menu.ChatList:Clear()
	menu.ResultList:Clear()
	if res.reason == 2 || res.reason == 3 then
		menu.WinningTeam:SetText(team.GetName(res.reason) .. " win!")
		menu.WinningTeam:SetColor(team.GetColor(res.reason))
	else
		menu.WinningTeam:SetText("Round tied")
		menu.WinningTeam:SetColor(Color(150, 150, 150))
	end

	//randomise award order, preserve keys
	local random = {}
	for k, award in pairs(awards) do
		table.insert(random, math.random(#random) + 1, {k, award})
	end

	for _, v in pairs(random) do
		local k, award = v[1], v[2]
		if res.playerAwards[k] then
			local t = res.playerAwards[k]
			local pnl = vgui.Create("DPanel")
			pnl:SetTall(math.max(draw.GetFontHeight("RobotoHUD-35"), draw.GetFontHeight("RobotoHUD-15") + draw.GetFontHeight("RobotoHUD-20") * 1.1))
			function pnl:Paint(w, h)
				surface.SetDrawColor(50, 50, 50)
				-- surface.DrawOutlinedRect(0, 0, w, h)
				draw.DrawText(award.name, "RobotoHUD-20", 0, 0, Color(220, 220, 220), 0)
				draw.DrawText(award.desc, "RobotoHUD-15", 0, draw.GetFontHeight("RobotoHUD-20"), Color(120, 120, 120), 0)
				draw.DrawText(t.name, "RobotoHUD-25", w, h / 2 - draw.GetFontHeight("RobotoHUD-25") / 2, t.color, 2)
			end

			menu.ResultList:AddItem(pnl)
		end
	end
end

function GM:EndRoundMapVote()
	self:OpenEndRoundMenu()

	menu.ResultsPanel:SetVisible(false)
	menu.VotePanel:SetVisible(true)

	menu.MapVoteList:Clear()

	for k, map in pairs(self.MapList) do
		local but = vgui.Create("DButton")
		but:SetText("")
		but:SetTall(128)
		local png
		local path = "maps/" .. map .. ".png"
		if file.Exists(path, "GAME") then
			png = Material(path, "noclamp")
		else
			local path = "maps/thumb/" .. map .. ".png"
			if file.Exists(path, "GAME") then
				png = Material(path, "noclamp")
			else
				local path = "materials/maps/" .. map .. ".png"
				if file.Exists(path, "GAME") then
					png = Material(path, "noclamp")
				end
			end
		end
		local dname = map:gsub("^%a%a%a?_", ""):gsub("_?v[%d%.%-]+$", "")
		dname = dname:gsub("[_]", " "):gsub("([%a])([%a]+)", function (a, b) return a:upper() .. b end)
		local z = tonumber(util.CRC(dname):sub(1, 8))
		local mcol = Color(z % 255, z / 255 % 255, z / 255 / 255 % 255, 50)
		local gray = Color(150, 150, 150)

		but.VotesScroll = 0
		but.VotesScrollDir = 1
		function but:Paint(w, h)
			if self.Hovered then
				surface.SetDrawColor(50, 50, 50, 50)
				surface.DrawRect(0, 0, w, h)
			end

			draw.SimpleText(dname, "RobotoHUD-20", 128 + 20, 20, color_white, 0)
			local fg = draw.GetFontHeight("RobotoHUD-20")
			draw.SimpleText(map, "RobotoHUD-L15", 128 + 20, 20 + fg, gray, 0)
			if png then
				surface.SetMaterial(png)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(0, 0, 128, 128)
			else
				surface.SetDrawColor(50, 50, 50, 255)
				surface.DrawRect(0, 0, 128, 128)
				surface.SetDrawColor(mcol)
				surface.DrawRect(20, 20, 128 - 40, 128 - 40)
			end

			local votes = 0
			if GAMEMODE.MapVotesByMap[map] then
				votes = #GAMEMODE.MapVotesByMap[map]
			end

			local fg2 = draw.GetFontHeight("RobotoHUD-L15")
			if votes > 0 then
				draw.SimpleText(votes .. (votes > 1 and " votes" or " vote"), "RobotoHUD-L15", 128 + 20, 20 + fg + 20 + fg2, color_white, 0)
			end

			local i = 0
			for ply, map2 in pairs(GAMEMODE.MapVotes) do
				if IsValid(ply) && map2 == map then
					draw.SimpleText(ply:Nick(), "RobotoHUD-L15", w, i * fg2 - self.VotesScroll, gray, 2)
					i = i + 1
				end
			end

			if i * fg2 > 128 then
				self.VotesScroll = self.VotesScroll + FrameTime() * 14 * self.VotesScrollDir
				if self.VotesScroll > i * fg2 - 128 then
					self.VotesScrollDir = -1
				elseif self.VotesScroll < 0 then
					self.VotesScrollDir = 1
				end
			end
		end

		function but:DoClick()
			RunConsoleCommand("ph_votemap", map)
		end
		menu.MapVoteList:AddItem(but)
	end
end

function GM:EndRoundAddChatText(...)
	if !IsValid(menu) then
		return
	end

	local pnl = vgui.Create("DPanel")
	pnl.Text = {...}
	function pnl:PerformLayout()
		if self.Text then
			self.TextLines = WrapText("RobotoHUD-15", self:GetWide() - 16, self.Text)
		end
		if self.TextLines then
			self:SetTall(self.TextLines.height)
		end
	end

	function pnl:Paint(w, h)
		-- surface.SetDrawColor(255, 0, 0, 255)
		-- surface.DrawOutlinedRect(0, 0, w, h)
		if self.TextLines then
			self.TextLines:Paint(4, draw.GetFontHeight("RobotoHUD-15") * -0.2)
		end
	end
	menu.ChatList:AddItem(pnl)
end

function GM:CloseRoundMenu()
	if IsValid(menu) then
		menu:SetVisible(false)
	end
end