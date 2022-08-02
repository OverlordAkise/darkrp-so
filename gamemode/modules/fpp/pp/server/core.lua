FPP = FPP or {}

local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

--[[-------------------------------------------------------------------------
Checks if a model is blocked
---------------------------------------------------------------------------]]
function FPP.IsBlockedModel(model,ply)
    --TODO: If ply and IsValid(ply) and RescueModeActive(ply) then return true end
    if model == "" or not FPP.Settings or not FPP.Settings.FPP_BLOCKMODELSETTINGS1 or
        not tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.toggle)
        or not FPP.BlockedModels or not model then return end

    model = string.lower(model or "")
    model = string.Replace(model, "\\", "/")
    model = string.gsub(model, "[\\/]+", "/")

    if string.find(model, "../", 1, true) then
        return true, "The model path goes up in the folder tree."
    end

    local found = FPP.BlockedModels[model]
    --To create a whitelist instead: Change the following code to "if not found then"
    if found then
        return true, "The model of this entity is in the black list!"
    end
    return false
end

--[[-------------------------------------------------------------------------
Prevents spawning a prop or effect when its model is blocked
---------------------------------------------------------------------------]]
local function propSpawn(ply, model)
    local blocked, msg = FPP.IsBlockedModel(model,ply)
    if blocked then
        FPP.Notify(ply, msg, false)
        return false
    end
end
hook.Add("PlayerSpawnObject", "FPP_SpawnEffect", propSpawn) -- prevents precaching
hook.Add("PlayerSpawnProp", "FPP_SpawnProp", propSpawn) -- PlayerSpawnObject isn't always called
hook.Add("PlayerSpawnEffect", "FPP_SpawnEffect", propSpawn)
hook.Add("PlayerSpawnRagdoll", "FPP_SpawnEffect", propSpawn)

--[[-------------------------------------------------------------------------
Setting owner when someone spawns something
---------------------------------------------------------------------------]]
if cleanup then
    FPP.oldcleanup = FPP.oldcleanup or cleanup.Add
    function cleanup.Add(ply, Type, ent)
        if not IsValid(ply) or not IsValid(ent) then return FPP.oldcleanup(ply, Type, ent) end

        --Set the owner of the entity
        ent:CPPISetOwner(ply)

        if not tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.propsonly) then
            local model = ent.GetModel and ent:GetModel()
            local blocked, msg = FPP.IsBlockedModel(model)

            if blocked then
                FPP.Notify(ply, msg, false)
                ent:Remove()

                return
            end
        end

        if FPP.AntiSpam and Type ~= "constraints" and Type ~= "stacks" and Type ~= "AdvDupe2" and (not AdvDupe2 or not AdvDupe2.SpawningEntity) and (not ent.IsVehicle or not ent:IsVehicle()) then
            FPP.AntiSpam.CreateEntity(ply, ent, Type == "duplicates")
        end

        if ent:GetClass() == "gmod_wire_expression2" then
            ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        end

        return FPP.oldcleanup(ply, Type, ent)
    end
end

if PLAYER.AddCount then
    FPP.oldcount = FPP.oldcount or PLAYER.AddCount
    function PLAYER:AddCount(Type, ent)
        if not IsValid(self) or not IsValid(ent) then return FPP.oldcount(self, Type, ent) end
        --Set the owner of the entity
        ent:CPPISetOwner(self)
        return FPP.oldcount(self, Type, ent)
    end
end

local entSetCreator = ENTITY.SetCreator
if entSetCreator then
    function ENTITY:SetCreator(ply)
        self:CPPISetOwner(ply)
        entSetCreator(self, ply)
    end
end

if undo then
    local AddEntity, SetPlayer, Finish =  undo.AddEntity, undo.SetPlayer, undo.Finish
    local Undo = {}
    local UndoPlayer
    function undo.AddEntity(ent, ...)
        if not isbool(ent) and IsValid(ent) then table.insert(Undo, ent) end
        AddEntity(ent, ...)
    end

    function undo.SetPlayer(ply, ...)
        UndoPlayer = ply
        SetPlayer(ply, ...)
    end

    function undo.Finish(...)
        if IsValid(UndoPlayer) then
            for _, v in pairs(Undo) do
                v:CPPISetOwner(UndoPlayer)
            end
        end
        Undo = {}
        UndoPlayer = nil

        Finish(...)
    end
end

hook.Add("PlayerSpawnedSWEP", "FPP.Spawn.SWEP", function(ply, ent)
    ent:CPPISetOwner(ply)
end)

hook.Add("PlayerSpawnedSENT", "FPP.Spawn.SENT", function(ply, ent)
    ent:CPPISetOwner(ply)
end)

--------------------------------------------------------------------------------------
--The protecting itself
--------------------------------------------------------------------------------------

FPP.Protect = {}

--Physgun Pickup
function FPP.Protect.PhysgunPickup(ply, ent)
    if not tobool(FPP.Settings.FPP_PHYSGUN1.toggle) then if FPP.UnGhost then FPP.UnGhost(ply, ent) end return end
    if not ent:IsValid() then return end
    local cantouch
    local skipReturn = false

    if isfunction(ent.PhysgunPickup) then
        cantouch = ent:PhysgunPickup(ply, ent)
        -- Do not return the value, the gamemode will do this
        -- Allows other hooks to run
        skipReturn = true
    elseif ent.PhysgunPickup ~= nil then
        cantouch = ent.PhysgunPickup
    else
        cantouch = not ent:IsPlayer() and FPP.plyCanTouchEnt(ply, ent, "Physgun")
        skipReturn = ent:IsPlayer()
    end

    if cantouch and ent:GetClass() == "prop_physics" and FPP.AntiSpam.GhostFreeze then FPP.AntiSpam.GhostFreeze(ent,ent:GetPhysicsObject()) end
    if not cantouch and not skipReturn then return false end
end
hook.Add("PhysgunPickup", "FPP.Protect.PhysgunPickup", FPP.Protect.PhysgunPickup)

hook.Add("PhysgunDrop", "so_FPP.Protect.PhysgunDrop", function(ply,ent)
    if ent:GetClass() == "prop_physics" and FPP.AntiSpam.GhostFreeze then FPP.AntiSpam.GhostFreeze(ent,ent:GetPhysicsObject()) end
end)

--Fuck Physgun reload
function FPP.Protect.PhysgunReload(weapon, ply)
    return false
end
hook.Add("OnPhysgunReload", "FPP.Protect.PhysgunReload", FPP.Protect.PhysgunReload)

function FPP.PhysgunFreeze(weapon, phys, ent, ply)
    if FPP.UnGhost then 
        timer.Simple(0.2,function()
            if not IsValid(ent) then return end
            if ent:GetClass() == "prop_physics" then FPP.UnGhost(ply, ent) end
        end)
    end
    if isfunction(ent.OnPhysgunFreeze) then
        local val = ent:OnPhysgunFreeze(weapon, phys, ent, ply)
        -- Do not return the value, the gamemode will do this
        if val ~= nil then return end
    elseif ent.OnPhysgunFreeze ~= nil then
        return ent.OnPhysgunFreeze
    end
end
hook.Add("OnPhysgunFreeze", "FPP.Protect.PhysgunFreeze", FPP.PhysgunFreeze)

--Toolgun
--for advanced duplicator, you can't use the IsWeapon function
local allweapons = {
["weapon_crowbar"] = true,
["weapon_physgun"] = true,
["weapon_physcannon"] = true,
["weapon_pistol"] = true,
["weapon_stunstick"] = true,
["weapon_357"] = true,
["weapon_smg1"] = true,
["weapon_ar2"] = true,
["weapon_shotgun"] = true,
["weapon_crossbow"] = true,
["weapon_frag"] = true,
["weapon_rpg"] = true,
["gmod_camera"] = true,
["gmod_tool"] = true,
["weapon_bugbait"] = true}

timer.Simple(5, function()
    for _, v in ipairs(weapons.GetList()) do
        if v.ClassName then allweapons[string.lower(v.ClassName or "")] = true end
    end
end)

local invalidToolData = {
    ["model"] = {
        "*",
        "\\"
    },
    ["material"] = {
        "*",
        "\\",
        " ",
        "effects/highfive_red",
        "pp/copy",
        ".v",
        "skybox/"
    },
    ["sound"] = {
        "?",
        " "
    },
    ["soundname"] = {
        " ",
        "?"
    },
    ["tracer"] = {
        "dof_node"
    },
    ["door_class"] = {
        "env_laser"
    },
    -- Limit wheel torque
    ["rx"] = 360,
    ["ry"] = 360,
    ["rz"] = 360
}
invalidToolData.override = invalidToolData.material
invalidToolData.rope_material = invalidToolData.material

function FPP.Protect.CanTool(ply, trace, tool, ENT)
    if FPP.Blocked.Toolgun1[trace.Entity:GetClass()] then return false end
    -- Anti server crash
    if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().GetToolObject and ply:GetActiveWeapon():GetToolObject() then
        local toolObj = ply:GetActiveWeapon():GetToolObject()
        for t, block in pairs(invalidToolData) do
            local clientInfo = string.lower(toolObj:GetClientInfo(t) or "")
            -- Check for number limits
            if isnumber(block) then
                local num = tonumber(clientInfo) or 0
                if num > block or num < -block then
                    FPP.Notify(ply, "The client settings of the tool are invalid!", false)
                    return false
                end
                continue
            end

            for _, item in pairs(block) do
                if string.find(clientInfo, item, 1, true) then
                    FPP.Notify(ply, "The client settings of the tool are invalid!", false)
                    return false
                end
            end
        end
    end
    if not IsTeam(ply) and not ply:IsAdmin() and not ALLOWED_TOOLS[tool] then return false end
    if ply:IsAdmin() then return true end
    
    if tool ~= "adv_duplicator" and tool ~= "duplicator" and tool ~= "advdupe2" then return end
    if not ENT then return false end

    local EntTable =
        (tool == "adv_duplicator" and ply:GetActiveWeapon():GetToolObject().Entities) or
        (tool == "advdupe2" and ply.AdvDupe2 and ply.AdvDupe2.Entities) or
        (tool == "duplicator" and ply.CurrentDupe and ply.CurrentDupe.Entities)

    if not EntTable then return end

    for k, v in pairs(EntTable) do
        local lowerClass = string.lower(v.Class)
        if IsTeam(ply) then continue end
        if allweapons[lowerClass] or string.find(lowerClass, "ai_") == 1 or string.find(lowerClass, "item_ammo_") == 1 then
            FPP.Notify(ply, "Duplicating blocked entity " .. lowerClass, false)
            EntTable[k] = nil
        end
        
        if FPP.Blocked.Spawning1[lowerClass] then
            FPP.Notify(ply, "Duplicating blocked entity " .. lowerClass, false)
            EntTable[k] = nil
        end

        if v and IsValid(v) and v.Model and FPP.BlockedModels[v.Model] then
            FPP.Notify(ply, "Duplicating blocked model " .. lowerClass, false)
            EntTable[k] = nil
        end
    end
    return
end
hook.Add("CanTool", "FPP.Protect.CanTool", FPP.Protect.CanTool)

function FPP.Protect.CanEditVariable(ent, ply, key, varVal, editTbl)
    if ply:IsAdmin() then return true end
    local val = FPP.Protect.CanProperty(ply, "editentity", ent)
    if val ~= nil then return val end
end
hook.Add("CanEditVariable", "FPP.Protect.CanEditVariable", FPP.Protect.CanEditVariable)

function FPP.Protect.CanProperty(ply, property, ent)
    if ply:IsAdmin() then return true end
    local cantouch = FPP.plyCanTouchEnt(ply, ent, "Toolgun")

    if not cantouch then return false end
end
hook.Add("CanProperty", "FPP.Protect.CanProperty", FPP.Protect.CanProperty)

--Player disconnect, not part of the Protect table.
function FPP.PlayerDisconnect(ply)
    if not IsValid(ply) then return end

    local SteamID = ply:SteamID()

    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == SteamID then
            return
        end
    end
    for _, v in ipairs(ents.GetAll()) do
        if v.FPPOwnerID ~= SteamID or v:GetPersistent() then continue end
        v:Remove()
    end
end
hook.Add("PlayerDisconnected", "FPP.PlayerDisconnect", FPP.PlayerDisconnect)

local backup = ENTITY.FireBullets
local blockedEffects = {"particleeffect", "smoke", "vortdispel", "helicoptermegabomb"}

function ENTITY:FireBullets(bullet, ...)
    if not bullet.TracerName then return backup(self, bullet, ...) end
    if table.HasValue(blockedEffects, string.lower(bullet.TracerName)) then
        bullet.TracerName = ""
    end
    return backup(self, bullet, ...)
end

-- Hydraulic exploit workaround
-- One should not be able to constrain doors to anything
local canConstrain = constraint.CanConstrain
local disallowedConstraints = {
    ["prop_door_rotating"] = true,
    ["func_door"] = true,
    ["func_breakable_surf"] = true
}
function constraint.CanConstrain(ent, bone)
    if IsValid(ent) and disallowedConstraints[string.lower(ent:GetClass())] then return false end

    return canConstrain(ent, bone)
end

-- Crash exploit workaround
local setAngles = ENTITY.SetAngles
function ENTITY:SetAngles(ang)
    if not ang then return setAngles(self, ang) end

    ang.p = ang.p % 360
    ang.y = ang.y % 360
    ang.r = ang.r % 360

    return setAngles(self, ang)
end
