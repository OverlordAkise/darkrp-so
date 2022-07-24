FPP = FPP or {}

hook.Add("CanTool", "FPP_CL_CanTool", function(ply, trace, tool) -- Prevent client from SEEING his toolgun shoot while it doesn't shoot serverside.
    if IsValid(trace.Entity) and not FPP.canTouchEnt(trace.Entity, "Toolgun") then
        return false
    end
end)

-- This looks weird, but whenever a client touches an ent he can't touch, without the code it'll look like he picked it up. WITH the code it really looks like he can't
-- besides, when the client CAN pick up a prop, it also looks like he can.
hook.Add("PhysgunPickup", "FPP_CL_PhysgunPickup", function(ply, ent)
    if not FPP.canTouchEnt(ent, "Physgun") then
        return false
    end
end)

-- Makes sure the client doesn't think they can punt props
hook.Add("GravGunPunt", "FPP_CL_GravGunPunt", function(ply, ent)
    if tobool(FPP.Settings.FPP_GRAVGUN1.noshooting) then return false end
    if IsValid(ent) and not FPP.canTouchEnt(ent, "Gravgun") then
        return false
    end
end)

local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_SetDrawColor = surface.SetDrawColor

local draw_DrawText = draw.DrawText
local draw_RoundedBox = draw.RoundedBox

--Notify ripped off the Sandbox notify, changed to my likings
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

    surface_SetFont("Default")
    local w,h = surface_GetTextSize(reason)
    local col = FPP.canTouchEnt(LAEnt, touchType) and canTouchTextColor or cannotTouchTextColor
    local scrH = ScrH()

    draw_RoundedBox(4, 0, scrH / 2 - h - 2, w + 10, 20, boxBackground)
    draw_DrawText(reason, "Default", 5, scrH / 2 - h, col, 0)
    surface_SetDrawColor(255, 255, 255, 255)
end)
