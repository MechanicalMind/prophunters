

local function createRoboto(s)
	surface.CreateFont( "RobotoHUD-" .. s , {
		font = "Roboto-Bold",
		size = math.Round(ScrW() / 1000 * s),
		weight = 700,
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

	self:DrawHealthFace(ply)
end

function GM:CreateHealthFace(ply)
	self.HealthFace = ClientsideModel(ply:GetModel(), RENDER_GROUP_OPAQUE_ENTITY)
	self.HealthFace:SetNoDraw( true )
		local iSeq = self.HealthFace:LookupSequence( "walk_all" );
	if ( iSeq <= 0 ) then iSeq = self.HealthFace:LookupSequence( "WalkUnarmed_all" ) end
	if ( iSeq <= 0 ) then iSeq = self.HealthFace:LookupSequence( "walk_all_moderate" ) end
	
	-- if ( iSeq > 0 ) then self.HealthFace:ResetSequence( iSeq ) end

	local f = function (self) return self.PlayerColor or Vector(1, 0, 0) end
	self.HealthFace.GetPlayerColorOverride = f
end

function GM:DrawHealthFace(ply)
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

	-- if !IsValid(self.HealthFace) then
	-- 	self:CreateHealthFace(ply)
	-- end

	-- if IsValid(self.HealthFace) then
	-- 	if self.HealthFace:GetModel() != ply:GetModel() then
	-- 		self:CreateHealthFace(ply)
	-- 	end	

	-- 	self.HealthFace.PlayerColor = ply:GetPlayerColor()

	-- 	local bone = self.HealthFace:LookupBone("ValveBiped.Bip01_Head1")
	-- 	local pos = Vector(0, 0, 0)
	-- 	local bang = Angle()
	-- 	if bone then
	-- 		pos, bang = self.HealthFace:GetBonePosition(bone)
	-- 	end

	-- 	cam.Start3D( pos + Vector(19, 0, 2), Vector(-1,0,0):Angle(), 70, x, y, w, h, 5, 4096 )
	-- 	cam.IgnoreZ( true )
		
	-- 	render.OverrideDepthEnable( false )
	-- 	render.SuppressEngineLighting( true )
	-- 	render.SetLightingOrigin(pos)
	-- 	render.ResetModelLighting(1, 1, 1)
	-- 	render.SetColorModulation(1, 1, 1)
	-- 	render.SetBlend(1)
		
	-- 	self.HealthFace:DrawModel()
		
	-- 	render.SuppressEngineLighting( false )
	-- 	cam.IgnoreZ( false )
	-- 	cam.End3D()

	-- end

	local health = client:Health()
	local maxhealth = client:GetHMaxHealth()

	local nh = math.Round(h * math.Clamp(health / maxhealth, 0, 1))
	surface.SetDrawColor(0, 150, 220, 150)
	surface.DrawRect(x, y + h - nh, w, nh)

	render.SetStencilEnable( false )
 
	render.SetStencilWriteMask( 0 );
		render.SetStencilReferenceValue( 0 );
		render.SetStencilTestMask( 0 );
		render.SetStencilEnable( false )
		render.OverrideDepthEnable( false )
		render.SetBlend( 1 )
		
		cam.IgnoreZ( false )
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
	if name == "CHudAmmo" then return false end
	return true
end

function GM:DrawRoundTimer()

	if self:GetGameState() == 1 then
		local time = math.ceil(30 - self:GetStateRunningTime())
		if time > 0 then
			draw.ShadowText(time, "RobotoHUD-40", ScrW() / 2, ScrH() / 3, color_white, 1, 1)
		end
	elseif self:GetGameState() == 2 then
		if self:GetStateRunningTime() < 2 then
			draw.ShadowText("GO!", "RobotoHUD-50", ScrW() / 2, ScrH() / 3, color_white, 1, 1)
		end
	end
end

function GM:RenderScreenspaceEffects()
	local client = LocalPlayer()
	if !client:Alive() then
	end

	if self:GetGameState() == 1 then
		if client:Team() == 2 then
			surface.SetDrawColor(25, 25, 25, 255)
			surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
		end
	end


end