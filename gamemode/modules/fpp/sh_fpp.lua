FPP = FPP or {}

local function isConstraint(ent)
    return ent:IsConstraint() or ent:GetClass() == "phys_spring" or false
end

--[[-------------------------------------------------------------------------
Touch calculations
---------------------------------------------------------------------------]]
local hardWhiteListed = { -- things that mess up when not allowed
    ["worldspawn"] = true, -- constraints with the world
    ["gmod_anchor"] = true -- used in slider constraints with world
}

local blockedEnts = {
    ["ai_network"] = true,
    ["network"] = true, -- alternative name for ai_network
    ["ambient_generic"] = true,
    ["beam"] = true,
    ["bodyque"] = true,
    ["env_soundscape"] = true,
    ["env_sprite"] = true,
    ["env_sun"] = true,
    ["env_tonemap_controller"] = true,
    ["func_useableladder"] = true,
    ["gmod_hands"] = true,
    ["info_ladder_dismount"] = true,
    ["info_player_start"] = true,
    ["info_player_terrorist"] = true,
    ["light_environment"] = true,
    ["light_spot"] = true,
    ["physgun_beam"] = true,
    ["player_manager"] = true,
    ["point_spotlight"] = true,
    ["predicted_viewmodel"] = true,
    ["scene_manager"] = true,
    ["shadow_control"] = true,
    ["soundent"] = true,
    ["spotlight_end"] = true,
    ["water_lod_control"] = true,
    ["gmod_gamerules"] = true,
    ["bodyqueue"] = true,
    ["phys_bone_follower"] = true,
}


--[[-------------------------------------------------------------------------
Touch interface
---------------------------------------------------------------------------]]
function FPP.plyCanTouchEnt(ply, ent, touchType)
    --TODO: If RescueModeActive() and ply:IsAdmin() then return true end
    --TODO: if config.StaffCanTouchLikeAdmins and IsTeam(ply)
    -- TODO: Check blacklist for e.g. toolgun for "blocked", physgun for "blocked", etc.
    if blockedEnts[ent:GetClass()] then return false end
    if unOwnableDoors[ent:GetClass()] then return false end
    if ply:IsAdmin() then return true end
    
    return false
end

function FPP.entGetOwner(ent)
    local owner = ent:GetOwner()
    if not owner then
        owner = ent:GetNWEntity("fppOwner",nil)
    end
    return owner
end

function FPP.entGetTouchReason(ent, touchType)
    local reason = "idk"
    local owner = FPP.entGetOwner(ent)
    
    if IsValid(owner) and owner:IsPlayer() then reason = owner:Nick() end
    if not IsValid(owner) then
        reason = "world"
    end
    --TODO: if ent:GetClass() == blocked then
    return reason
end

--
-- Compatibility
--


function FPP.RecalculateConstrainedEntities() end
function FPP.calculateCanTouch() return false end
function FPP.recalculateCanTouch() end
function FPP.plySendTouchData() end
function FPP.FillDefaultBlocked() end
function FPP.AddDefaultBlocked() end

FPP.Blocked = FPP.Blocked or {}
FPP.Blocked.PlayerUse1 = {}
FPP.Blocked.EntityDamage1 = {}
FPP.RestrictedTools = {}
FPP.RestrictedToolsPlayers = {}
FPP.Groups = {}
FPP.GroupMembers = {}
FPP.DisconnectedPlayers = FPP.DisconnectedPlayers or {}

if CLIENT then
    function FPP.canTouchEnt(ent, touchType)
        return FPP.plyCanTouchEnt(LocalPlayer(),ent,touchType)
    end
end
