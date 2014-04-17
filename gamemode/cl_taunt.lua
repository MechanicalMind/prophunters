local taunts = {}
local tauntcategories = {}

local function addTaunt(name, snd, sex, cats)
	local t = {}
	t.sound = snd
	t.categories = cats
	if sex && #sex > 0 then
		t.sex = sex
	end
	t.name = name

	table.insert(taunts, t)
	for k, cat in pairs(cats) do
		if !tauntcategories[cat] then tauntcategories[cat] = {} end
		table.insert(tauntcategories[cat], t)
	end
end

addTaunt("About Time", {"vo/npc/male01/abouttime01.wav", "vo/npc/male01/abouttime02.wav"}, "male", {"npc", "3sec"})


local menu

local gradU = surface.GetTextureID("gui/gradient_up")
local gradD = surface.GetTextureID("gui/gradient_down")

concommand.Add("ph_menu_taunt", function ()
	if IsValid(menu) then
		menu:Remove()
	end

	menu = vgui.Create("DFrame")
	menu:SetSize(ScrW() * 0.3, ScrH() * 0.8)
	menu:Center()
	menu:SetTitle("Taunts")
	menu:MakePopup()
	menu:SetKeyboardInputEnabled(false)
	menu:SetDeleteOnClose(true)
	menu:SetDraggable(false)
	menu:ShowCloseButton(true)


	local mlist = vgui.Create("DScrollPanel", menu)
	mlist:Dock(FILL)
	function mlist:Paint(w, h)
		
	end

	// child positioning
	local canvas = mlist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock( TOP )
		child:DockMargin( 0,0,0,4 )
	end

	for k, t in pairs(taunts) do
		local but = vgui.Create("DButton")
		but:SetTall(draw.GetFontHeight("RobotoHUD-20"))
		but:SetText("")
		function but:Paint(w, h)
			surface.SetDrawColor(70, 70, 70)
			surface.DrawRect(0, 0, w, h)
		
			if self:IsDown() then
				surface.SetDrawColor(60, 60, 60)
				surface.DrawRect(0, 0, w, h)
			elseif self:IsHovered() then
				surface.SetDrawColor(80, 80, 80)
				surface.DrawRect(0, 0, w, h)
			else
			end
			surface.SetTexture(gradU)
			surface.SetDrawColor(20, 20, 20, 80)
			surface.DrawTexturedRect(1, 1, w - 2, h - 2)

			draw.ShadowText(t.name, "RobotoHUD-20", w / 2, 0, color_white, 1)
			draw.ShadowText(math.Round(SoundDuration(t.sound[1]) * 10) / 10 .. "s", "RobotoHUD-20", w - 4, 0, color_white, 2)
		end
		mlist:AddItem(but)
	end
end)