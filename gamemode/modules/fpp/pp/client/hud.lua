FPP = FPP or {}

hook.Add("CanTool", "FPP_CL_CanTool", function(ply, trace, tool)--fixes graphical glitches
    if IsValid(trace.Entity) and not FPP.plyCanTouchEnt(LocalPlayer(), trace.Entity, "Toolgun") then
        return false
    end
end)

hook.Add("PhysgunPickup", "FPP_CL_PhysgunPickup", function(ply, ent)--fixes graphical glitches
    if not FPP.plyCanTouchEnt(LocalPlayer(), ent, "Physgun") then
        return false
    end
end)

-- Makes sure the client doesn't think they can punt props
hook.Add("GravGunPunt", "FPP_CL_GravGunPunt", function(ply, ent)
    if tobool(FPP.Settings.FPP_GRAVGUN1.noshooting) then return false end
    if IsValid(ent) and not FPP.plyCanTouchEnt(LocalPlayer(), ent, "Gravgun") then
        return false
    end
end)

function FPP.AddNotify( str, isGreen )
    notification.AddLegacy(str, isGreen and 0 or 1, 5)
    LocalPlayer():EmitSound("npc/turret_floor/click1.wav", 10, 100)
end
net.Receive("FPP_Notify", function() FPP.AddNotify(net.ReadString(), net.ReadBool()) end)

local weaponClassTouchTypes = {
    ["weapon_physgun"] = "Physgun",
    ["weapon_physcannon"] = "Gravgun",
    ["gmod_tool"] = "Toolgun",
}

local boxBackground = Color(0, 0, 0, 110)
local canTouchTextColor = Color(0, 255, 0, 255)
local cannotTouchTextColor = Color(255, 0, 0, 255)

hook.Add("HUDPaint", "FPP_HUDPaint", function()
    if FPP.getPrivateSetting("HideOwner") then return end
    --Show the owner:
    local ply = LocalPlayer()
    local eyetrace = ply:GetEyeTrace()
    if not eyetrace then return end
    local LAEnt = eyetrace.Entity
    if not LAEnt or not IsValid(LAEnt) then return end
    local weapon = ply:GetActiveWeapon()
    local class = weapon:IsValid() and weapon:GetClass() or ""
    local touchType = weaponClassTouchTypes[class] or "EntityDamage"
    local reason = FPP.entGetTouchReason(LAEnt, touchType)
    if not reason then return end
    local originalOwner = LAEnt:GetNW2String("FPP_OriginalOwner")
    originalOwner = originalOwner ~= "" and (" (previous owner: %s)"):format(originalOwner) or ""
    reason = reason .. originalOwner

    surface.SetFont("Default")
    local w,h = surface.GetTextSize(reason)
    local col = FPP.plyCanTouchEnt(LocalPlayer(), LAEnt, touchType) and canTouchTextColor or cannotTouchTextColor
    local scrH = ScrH()

    draw.RoundedBox(4, 0, scrH / 2 - h - 2, w + 10, 20, boxBackground)
    draw.DrawText(reason, "Default", 5, scrH / 2 - h, col, 0)
    surface.SetDrawColor(255, 255, 255, 255)
end)
