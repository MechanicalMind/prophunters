include("shared.lua")

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModelFOV = 65

SWEP.Slot = 0
SWEP.SlotPos = 1

killicon.AddFont( "weapon_mu_knife", "HL2MPTypeDeath", "5", Color( 0, 0, 255, 255 ) )

function SWEP:DrawWeaponSelection( x, y, w, h, alpha )
	draw.DrawText("Knife", "Default", x + w * 0.5, y + h * 0.5, Color(255, 150, 0, alpha), 1)
end

function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:DrawViewModel()	
	return false
end

function SWEP:DrawWorldModel()	
	self:DrawModel()
	return false
end


function SWEP:DrawHUD()
end  
