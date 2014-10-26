

local function createRoboto(s)
	surface.CreateFont( "RobotoHUD-" .. s , {
		font = "Roboto-Bold",
		size = math.Round(ScrW() / 1000 * s),
		weight = 700,
		antialias = true,
		italic = false
	})
	surface.CreateFont( "RobotoHUD-L" .. s , {
		font = "Roboto",
		size = math.Round(ScrW() / 1000 * s),
		weight = 500,
		antialias = true,
		italic = false
	})
end

for i = 5, 50, 5 do
	createRoboto(i)
end
createRoboto(8)

function draw.ShadowText(n, f, x, y, c, px, py, shadowColor)
	draw.SimpleText(n, f, x + 1, y + 1, shadowColor or color_black, px, py)
	draw.SimpleText(n, f, x, y, c, px, py)
end

function draw.EasyPNG(path, x, y, w, h, col)
	surface.SetMaterial(Material(path, "noclamp"))
	if col then
		surface.SetDrawColor(col.r, col.g, col.b, col.a)
	else
		surface.SetDrawColor(255, 255, 255, 255)
	end
	surface.DrawTexturedRect(x, y, w, h)
end

local function translate(name)
	if name == "weapon_physcannon" then return "Gravity Gun" end
	return language.GetPhrase(name)
end

function GM:HUDPaint()
	if LocalPlayer():Alive() then
	end
	-- self:DrawMoney()
	self:DrawGameHUD()
	-- DebugInfo(1, tostring(LocalPlayer():GetVelocity():Length()))

	self:DrawRoundTimer()
	self:DrawKillFeed()
end

local helpKeysProps = {
	{"attack", "Disguise as prop"},
	{"menu_context", "Lock prop rotation"},
	{"gm_showspare1", "Taunt"}
}

local function keyName(str)
	str = input.LookupBinding(str)
	return str:upper()
end

function GM:DrawGameHUD()
	if LocalPlayer():Alive() then
	end

	local ply = LocalPlayer()
	if self:IsCSpectating() && IsValid(self:GetCSpectatee()) && self:GetCSpectatee():IsPlayer() then
		ply = self:GetCSpectatee()
	end
	self:DrawHealth(ply)

	if ply != LocalPlayer() then
		local col = ply:GetPlayerColor()
		col = Color(col.r * 255, col.y * 255, col.z * 255)
		draw.ShadowText(ply:Nick(), "RobotoHUD-30", ScrW() / 2, ScrH() - 4, col, 1, 4)
	end


	local tr = ply:GetEyeTraceNoCursor()

	local shouldDraw = hook.Run("HUDShouldDraw", "PropHuntersPlayerNames")
	if shouldDraw != false then
		// draw names
		if IsValid(tr.Entity) && tr.Entity:IsPlayer() && tr.HitPos:Distance(tr.StartPos) < 500 then
			// hunters can only see their teams names
			if ply:Team() != 2 || ply:Team() == tr.Entity:Team() then
				self.LastLooked = tr.Entity
				self.LookedFade = CurTime()
			end
		end
		if IsValid(self.LastLooked) && self.LookedFade + 2 > CurTime() then
			local name = self.LastLooked:Nick() or "error"
			local col = self.LastLooked:GetPlayerColor() or Vector()
			col = Color(col.x * 255, col.y * 255, col.z * 255)
			col.a = (1 - (CurTime() - self.LookedFade) / 2) * 255
			draw.ShadowText(name, "RobotoHUD-20", ScrW() / 2, ScrH() / 2 + 80, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, Color(0, 0, 0, col.a))
		end
	end


	local help 
	if LocalPlayer():Alive() then
		if LocalPlayer():Team() == 3 then
			if self:GetGameState() == 1 || (self:GetGameState() == 2 && !LocalPlayer():IsDisguised()) then
				help = helpKeysProps
			end
		end
	end



	if help then
		local fh = draw.GetFontHeight("RobotoHUD-L15")
		local w, h = math.ceil(ScrW() * 0.09), #help * fh
		local x = 20
		local y = ScrH() / 2 - h / 2

		local i = 0
		local tw = 0
		for k, t in pairs(help) do
			surface.SetFont("RobotoHUD-15")
			local name = keyName(t[1])
			local w,h = surface.GetTextSize(name)
			tw = math.max(tw, w)
		end
		for k, t in pairs(help) do
			surface.SetFont("RobotoHUD-15")
			local name = keyName(t[1])
			local w,h = surface.GetTextSize(name)
			draw.ShadowText(name, "RobotoHUD-15", x + tw / 2, y + i * fh, color_white, 1, 0)
			draw.ShadowText(t[2], "RobotoHUD-L15", x + tw + 10, y + i * fh, color_white, 0, 0)
			i = i + 1
		end
	end
end


local tex = surface.GetTextureID("mech/ring")
local ringThin = surface.GetTextureID("mech/ring_thin")
local matWhite = Material( "model_color" )
local rt_Store = render.GetScreenEffectTexture( 0 )
local mat_Copy = Material( "pp/copy" )

local polyTex = surface.GetTextureID("VGUI/white.vmt")

local function drawPoly(x, y, w, h, percent)
	local points = 40

	if percent > 0.5 then
		local vertexes = {}
		local hpoints = points / 2
		local base = math.pi * 1.5
		local mul = 1 / hpoints * math.pi
		for i = (1 - percent) * 2 * hpoints, hpoints do
			table.insert(vertexes, {x = x + w / 2 + math.cos(i * mul + base) * w / 2, y = y + h / 2 + math.sin(i * mul + base) * h / 2})
		end
		table.insert(vertexes, {x = x + w / 2, y = y + h})
		table.insert(vertexes, {x = x + w / 2, y = y + h / 2})

		-- for i = 1, #vertexes do draw.DrawText(i, "Default", vertexes[i].x, vertexes[i].y, color_white, 0) end

		surface.SetTexture(polyTex)
		surface.DrawPoly(vertexes)
	end

	local vertexes = {}
	local hpoints = points / 2
	local base = math.pi * 0.5
	local mul = 1 / hpoints * math.pi
	local p = 0
	if percent < 0.5 then
		p = (1 - percent * 2 )
	end
	for i = p * hpoints, hpoints do
		table.insert(vertexes, {x = x + w / 2 + math.cos(i * mul + base) * w / 2, y = y + h / 2 + math.sin(i * mul + base) * h / 2})
	end
	table.insert(vertexes, {x = x + w / 2, y = y})
	table.insert(vertexes, {x = x + w / 2, y = y + h / 2})

	-- for i = 1, #vertexes do draw.DrawText(i, "Default", vertexes[i].x, vertexes[i].y, color_white, 0) end

	surface.SetTexture(polyTex)
	surface.DrawPoly(vertexes)
end

function GM:DrawHealth(ply)

	local client = LocalPlayer()

	local x = 20
	local w,h = math.ceil(ScrW() * 0.09), 80
	h = w
	local y = ScrH() - 20 - h

	local ps = 0.05

	surface.SetDrawColor(50, 50, 50, 180)
	drawPoly(x, y, w, h, 1)

	render.ClearStencil()
	render.SetStencilEnable( true )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )
	render.SetStencilReferenceValue( 1 )

	render.SetBlend( 0 )

	render.OverrideDepthEnable( true, false )
	-- render.SetMaterial(matWhite)
	-- render.DrawScreenQuadEx(tx, ty, tw, th)

	surface.SetDrawColor(26, 120, 245, 1)
	drawPoly(x + w * ps, y + h * ps, w * (1 - 2 * ps), h * (1 - 2 * ps), 1)

	render.SetStencilEnable( true );
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue( 1 )

	local health = ply:Health()
	local maxhealth = math.max(health, ply:GetHMaxHealth())

	local nh = math.Round((h - ps * 2) * math.Clamp(health / maxhealth, 0, 1))
	local tcol = table.Copy(team.GetColor(ply:Team()))
	tcol.a = 150
	surface.SetDrawColor(tcol)
	surface.DrawRect(x, y + h - ps - nh, w, nh)

	draw.ShadowText(math.Round(health) .. "", "RobotoHUD-25", x + w / 2, y + h / 2, color_white, 1, 1)


	render.SetStencilEnable( false )
 
	render.SetStencilWriteMask( 0 );
		render.SetStencilReferenceValue( 0 );
		render.SetStencilTestMask( 0 );
		render.SetStencilEnable( false )
		render.OverrideDepthEnable( false )
		render.SetBlend( 1 )
		
		cam.IgnoreZ( false )

	if ply:IsDisguised() && ply:DisguiseRotationLocked() then
		local fg = draw.GetFontHeight("RobotoHUD-15")
		draw.ShadowText("ROTATION", "RobotoHUD-15", x + w + 20, y + h / 2 - fg / 2, color_white, 0, 1)
		draw.ShadowText("LOCK", "RobotoHUD-15", x + w + 20, y + h / 2 + fg / 2, color_white, 0, 1)
	end
end

function GM:DrawMoney()

	local x = 20 + 8
	local w, h = 0, draw.GetFontHeight("RobotoHUD-25")
	local y = ScrH() - 20 - math.ceil(ScrW() * 0.09) - 20 - h

	surface.SetFont("RobotoHUD-20")
	local tw, th = surface.GetTextSize("000000")

	surface.SetFont("RobotoHUD-25")
	local dw, dh = surface.GetTextSize("$")
	local gap = 4

	w = dw + gap + tw

	local dull = 220
	local dulla = 90

	surface.SetFont("RobotoHUD-25")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(x, y + h / 2 - dh / 2 - 3)
	surface.DrawText("$")

	local mone = self:GetMoney()
	if GAMEMODE.MoneyNotifTime && GAMEMODE.MoneyNotifTime + 3 > CurTime() then
		local add = "+" .. GAMEMODE.MoneyNotif
		mone = mone - GAMEMODE.MoneyNotif
		draw.ShadowText(add, "RobotoHUD-20", x + w + gap + 16, y + h / 2 - th / 2)
	end

	surface.SetFont("RobotoHUD-20")
	local money = tostring(mone):sub(1,6)
	if self:GetMoney() <= 0 then money = "" end
	if #money < 6 then
		surface.SetTextColor(dull, dull, dull, dulla)
		surface.SetTextPos(x + dw + gap, y + h / 2 - th / 2)
		surface.DrawText(("0"):rep(6 - #money))
	end

	local aw, ah = surface.GetTextSize(money)
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(x + dw + gap + (tw - aw), y + h / 2 - th / 2)
	surface.DrawText(money)

end

function GM:HUDShouldDraw(name)
	if name == "CHudHealth" then return false end
	if name == "CHudVoiceStatus" then return false end
	if name == "CHudVoiceSelfStatus" then return false end
	-- if name == "CHudAmmo" then return false end
	if name == "CHudChat" then
		if IsValid(self.EndRoundPanel) && self.EndRoundPanel:IsVisible() then
			return false
		end
	end
	return true
end

function GM:DrawRoundTimer()

	if self:GetGameState() == 1 then
		local time = math.ceil(30 - self:GetStateRunningTime())
		if time > 0 then
			draw.ShadowText("Hunters will be released in", "RobotoHUD-15", ScrW() / 2, ScrH() / 3 - draw.GetFontHeight("RobotoHUD-40") / 2, color_white, 1, 4)
			draw.ShadowText(time, "RobotoHUD-40", ScrW() / 2, ScrH() / 3, color_white, 1, 1)
		end
	elseif self:GetGameState() == 2 then
		if self:GetStateRunningTime() < 2 then
			draw.ShadowText("GO!", "RobotoHUD-50", ScrW() / 2, ScrH() / 3, color_white, 1, 1)
		end
		local settings = self:GetRoundSettings()
		local roundTime = settings.RoundTime or 5 * 60
		local time = math.max(0, roundTime - self:GetStateRunningTime())
		local m = math.floor(time / 60)
		local s = math.floor(time % 60)
		m = tostring(m)
		s = s < 10 and "0" .. s or tostring(s)
		local fh = draw.GetFontHeight("RobotoHUD-L15") * 1
		draw.ShadowText("Props win in", "RobotoHUD-L15", ScrW() / 2, 20, color_white, 1, 3)
		draw.ShadowText(m .. ":" .. s, "RobotoHUD-20", ScrW() / 2, fh + 20, color_white, 1, 3)
	end
end

local polyMat = Material("VGUI/white.vmt")
function GM:RenderScreenspaceEffects()
end
function GM:PreDrawHUD()
	local client = LocalPlayer()
	if !client:Alive() then
	end

	if self:GetGameState() == 1 then
		if client:Team() == 2 then
			surface.SetDrawColor(25, 25, 25, 255)
			surface.DrawRect(-10, -10, ScrW() + 20, ScrH() + 20)
		end
	end
end