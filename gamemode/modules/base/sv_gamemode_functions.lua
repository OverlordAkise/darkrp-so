local entMeta = FindMetaTable("Entity")

-- Maintains entities that are to be removed after disconnect
local queuedForRemoval = {}

function GM:Initialize()
    self.Sandbox.Initialize(self)
end

function GM:playerBuyDoor(ply, ent)
    return true
end

function GM:getDoorCost(ply, ent)
    return GAMEMODE.Config.doorcost ~= 0 and GAMEMODE.Config.doorcost or 30
end

function GM:getVehicleCost(ply, ent)
    return GAMEMODE.Config.vehiclecost ~= 0 and GAMEMODE.Config.vehiclecost or 40
end

local disallowedNames = {["ooc"] = true, ["shared"] = true, ["world"] = true, ["world prop"] = true}
function GM:CanChangeRPName(ply, RPname)
    if disallowedNames[string.lower(RPname)] then return false, DarkRP.getPhrase("forbidden_name") end
    if not string.match(RPname, "^[a-zA-ZЀ-џ0-9 ]+$") then return false, DarkRP.getPhrase("illegal_characters") end

    local len = string.len(RPname)
    if len > 30 then return false, DarkRP.getPhrase("too_long") end
    if len < 3 then return false,  DarkRP.getPhrase("too_short") end
end

function GM:playerWalletChanged(ply, amount) end
function GM:playerGetSalary(ply, amount) end
function GM:DarkRPVarChanged(ply, var, oldvar, newvalue) end
function GM:playerBoughtVehicle(ply, ent, cost) end
function GM:playerBoughtDoor(ply, ent, cost) end

function GM:canDropWeapon(ply, weapon)
    if not IsValid(weapon) then return false end
    local class = string.lower(weapon:GetClass())

    if not GAMEMODE.Config.dropspawnedweapons then
        local jobTable = ply:getJobTable()
        if jobTable.weapons and table.HasValue(jobTable.weapons, class) then return false end
    end

    if self.Config.DisallowDrop[class] then return false end

    if not GAMEMODE.Config.restrictdrop then return true end

    for _, v in pairs(CustomShipments) do
        if v.entity ~= class then continue end

        return true
    end

    return false
end

function GM:DatabaseInitialized()
    DarkRP.initDatabase()
end

function GM:canEarnNPCKillPay(ply, npc)
    return GAMEMODE.Config.npckillpay > 0
end

function GM:calculateNPCKillPay(ply, npc)
    -- A NPC spawned by an addon might be worth more money than the default
    if npc.KillValue then
        return npc.KillValue
    end
    return GAMEMODE.Config.npckillpay
end


function GM:PlayerSpawnProp(ply, model)
    --if not allowed by job
    if not ALLOWED_PROP_SPAWNING_JOBS or not ALLOWED_PROP_SPAWNING_JOBS[ply:getJobTable().name] then
        --if not staff then dont spawn props
        if not IsTeam(ply) then
            return false
        end
        --if not admin and spawnprops for staff is disabled: dont spawn props
        if not ply:IsAdmin() and IsTeam(ply) and not GM.Config.canStaffSpawnProps then
            return false
        end
    end

    model = string.gsub(tostring(model), "\\", "/")
    model = string.gsub(tostring(model), "//", "/")

    local jobTable = ply:getJobTable()
    if jobTable.PlayerSpawnProp then
        jobTable.PlayerSpawnProp(ply, model)
    end

    return self.Sandbox.PlayerSpawnProp(self, ply, model)
end

function GM:PlayerSpawnedProp(ply, model, ent)
    self.Sandbox.PlayerSpawnedProp(self, ply, model, ent)
    ent.SID = ply.SID
    ent:CPPISetOwner(ply)

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        ent.RPOriginalMass = phys:GetMass()
    end

    if GAMEMODE.Config.proppaying then
        if ply:canAfford(GAMEMODE.Config.propcost) then
            DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("deducted_money", DarkRP.formatMoney(GAMEMODE.Config.propcost)))
            ply:addMoney(-GAMEMODE.Config.propcost)
        else
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_money", DarkRP.formatMoney(GAMEMODE.Config.propcost)))
            SafeRemoveEntity(ent)
            return false
        end
    end
end


local function checkAdminSpawn(ply, configVar, errorStr)
    local config = GAMEMODE.Config[configVar]
    --staff can spawn if allowed
    if config and IsTeam(ply) then
        return true
    end
    --admins can always spawn
    if not config and ply:IsAdmin() then
        return true
    end
    DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("need_admin", DarkRP.getPhrase(errorStr) or errorStr))
    return false
end

function GM:PlayerSpawnSENT(ply, class)
    return checkAdminSpawn(ply, "canStaffSpawnEntities", "gm_spawnsent") and self.Sandbox.PlayerSpawnSENT(self, ply, class)
end

function GM:PlayerSpawnedSENT(ply, ent)
    self.Sandbox.PlayerSpawnedSENT(self, ply, ent)
    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") spawned SENT " .. ent:GetClass(), Color(255, 255, 0))
end

local function canSpawnWeapon(ply)
    --staff can spawn if allowed
    if GAMEMODE.Config.canStaffSpawnWeapons and IsTeam(ply) then
        return true
    end
    --admins can always spawn
    if not GAMEMODE.Config.canStaffSpawnWeapons and ply:IsAdmin() then
        return true
    end
    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_spawn_weapons"))

    return false
end

function GM:PlayerSpawnSWEP(ply, class, info)
    return canSpawnWeapon(ply) and self.Sandbox.PlayerSpawnSWEP(self, ply, class, info)
end

function GM:PlayerGiveSWEP(ply, class, info)
    return canSpawnWeapon(ply) and self.Sandbox.PlayerGiveSWEP(self, ply, class, info)
end

function GM:PlayerSpawnEffect(ply, model)
    return self.Sandbox.PlayerSpawnEffect(self, ply, model)
end

function GM:PlayerSpawnVehicle(ply, model, class, info)
    return checkAdminSpawn(ply, "canStaffSpawnVehicles", "gm_spawnvehicle") and self.Sandbox.PlayerSpawnVehicle(self, ply, model, class, info)
end

function GM:PlayerSpawnedVehicle(ply, ent)
    self.Sandbox.PlayerSpawnedVehicle(self, ply, ent)
    local vehicleClass = ent.GetVehicleClass and " (" .. ent:GetVehicleClass() .. ")" or ""
    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") spawned Vehicle " .. ent:GetClass() .. vehicleClass, Color(255, 255, 0))
end

function GM:PlayerSpawnNPC(ply, type, weapon)
    return checkAdminSpawn(ply, "canStaffSpawnNpc", "gm_spawnnpc") and self.Sandbox.PlayerSpawnNPC(self, ply, type, weapon)
end

function GM:PlayerSpawnedNPC(ply, ent)
    self.Sandbox.PlayerSpawnedNPC(self, ply, ent)
    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") spawned NPC " .. ent:GetClass(), Color(255, 255, 0))
end

function GM:PlayerSpawnRagdoll(ply, model)
    return self.Sandbox.PlayerSpawnRagdoll(self, ply, model)
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
    self.Sandbox.PlayerSpawnedRagdoll(self, ply, model, ent)
    ent.SID = ply.SID
end

function GM:EntityRemoved(ent)
    self.Sandbox.EntityRemoved(self, ent)
    if ent:IsVehicle() then
        local found = ent:CPPIGetOwner()
        if IsValid(found) then
            found.Vehicles = found.Vehicles or 1
            found.Vehicles = found.Vehicles - 1
        end
    end

    local owner = ent.Getowning_ent and ent:Getowning_ent() or Player(ent.SID or 0)
    if ent.DarkRPItem and IsValid(owner) and not ent.IsPocketing then owner:removeCustomEntity(ent.DarkRPItem) end
    if ent.isKeysOwnable and ent:isKeysOwnable() then ent:removeDoorData() end
end

function GM:ShowSpare1(ply)
    local jobTable = ply:getJobTable()
    if jobTable.ShowSpare1 then
        return jobTable.ShowSpare1(ply)
    end
end
function GM:ShowSpare2(ply)
    local jobTable = ply:getJobTable()
    if jobTable.ShowSpare2 then
        return jobTable.ShowSpare2(ply)
    end
end
function GM:ShowTeam(ply) end
function GM:ShowHelp(ply) end

function GM:OnNPCKilled(victim, ent, weapon)
    if not ent then return end
    if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end
    if not ent:IsPlayer() then
        ent = Player(tonumber(ent.SID) or 0)
    end

    if IsValid(ent) and hook.Call("canEarnNPCKillPay", GAMEMODE, ent, victim) then
        local amount = hook.Call("calculateNPCKillPay", GAMEMODE, ent, victim)
        ent:addMoney(amount)
        DarkRP.notify(ent, 0, 4, DarkRP.getPhrase("npc_killpay", DarkRP.formatMoney(amount)))
    end
end

function GM:KeyPress(ply, code)
    self.Sandbox.KeyPress(self, ply, code)
end

-- IsInRoom function to see if the player is in the same room.
local roomTrResult = {}
local roomTr = { output = roomTrResult }
local function IsInRoom(listenerShootPos, talkerShootPos, talker)
    roomTr.start = talkerShootPos
    roomTr.endpos = listenerShootPos
    -- Listener needs not be ignored as that's the end of the trace
    roomTr.filter = talker
    roomTr.collisiongroup = COLLISION_GROUP_WORLD
    roomTr.mask = MASK_SOLID_BRUSHONLY
    util.TraceLine(roomTr)

    return not roomTrResult.HitWorld
end

local dynv = GM.Config.dynamicvoice
local deadv = GM.Config.deadvoice
local voiceDistance = GM.Config.voiceDistance * GM.Config.voiceDistance
local DrpCanHear = {}

-- Recreate DrpCanHear after Lua Refresh
-- This prevents an indexing nil error in PlayerCanHearPlayersVoice
for _, ply in pairs(player.GetAll()) do
    DrpCanHear[ply] = {}
end

local gridSize = GM.Config.voiceDistance -- Grid cell size is equal to the size of the radius of player talking
local floor = math.floor -- Caching floor as we will need to use it a lot

-- Grid based position check
local grid
-- Translate player to grid coordinates. The first table maps players to x
-- coordinates, the second table maps players to y coordinates.
local plyToGrid = {
    {},
    {}
}

-- Set DarkRP.voiceCheckTimeDelay before DarkRP is loaded to set the time
-- between player voice radius checks.
DarkRP.voiceCheckTimeDelay = DarkRP.voiceCheckTimeDelay or 0.3
timer.Create("DarkRPCanHearPlayersVoice", DarkRP.voiceCheckTimeDelay, 0, function()

    local players = player.GetHumans()

    -- Clear old values
    plyToGrid[1] = {}
    plyToGrid[2] = {}
    grid = {}

    local plyPos = {}
    local eyePos = {}

    -- Get the grid position of every player O(N)
    for _, ply in ipairs(players) do
        local pos = ply:GetPos()
        plyPos[ply] = pos
        eyePos[ply] = ply:EyePos()
        local x = floor(pos.x / gridSize)
        local y = floor(pos.y / gridSize)

        local row = grid[x] or {}
        local cell = row[y] or {}

        table.insert(cell, ply)
        row[y] = cell
        grid[x] = row

        plyToGrid[1][ply] = x
        plyToGrid[2][ply] = y

        DrpCanHear[ply] = {} -- Initialize output variable
    end

    -- Check all neighbouring cells for every player.
    -- We are only checking in 1 direction to avoid duplicate check of cells
    for _, ply1 in ipairs(players) do
        local gridX = plyToGrid[1][ply1]
        local gridY = plyToGrid[2][ply1]
        local ply1Pos = plyPos[ply1]
        local ply1EyePos = eyePos[ply1]

        for i = 0, 3 do
            local vOffset = 1 - ((i >= 3) and 1 or 0)
            local hOffset = -(i % 3-1)
            local x = gridX + hOffset
            local y = gridY + vOffset

            local row = grid[x]
            if not row then continue end

            local cell = row[y]
            if not cell then continue end

            for _, ply2 in ipairs(cell) do
                local canTalk =
                    ply1Pos:DistToSqr(plyPos[ply2]) < voiceDistance and -- voiceradius is on and the two are within hearing distance
                        (not dynv or IsInRoom(ply1EyePos, eyePos[ply2], ply2)) -- Dynamic voice is on and players are in the same room

                DrpCanHear[ply1][ply2] = canTalk and (deadv or ply2:Alive())
                DrpCanHear[ply2][ply1] = canTalk and (deadv or ply1:Alive()) -- Take advantage of the symmetry
            end
        end
    end

    -- Doing a pass-through inside every cell to compute the interactions inside of the cells.
    -- Each grid check is O(N(N+1)/2) where N is the number of players inside the cell.
    for _, row in pairs(grid) do
        for _, cell in pairs(row) do
            local count = #cell
            for i = 1, count do
                local ply1 = cell[i]
                for j = i + 1, count do
                    local ply2 = cell[j]
                    local canTalk =
                        plyPos[ply1]:DistToSqr(plyPos[ply2]) < voiceDistance and -- voiceradius is on and the two are within hearing distance
                            (not dynv or IsInRoom(eyePos[ply1], eyePos[ply2], ply2)) -- Dynamic voice is on and players are in the same room

                    DrpCanHear[ply1][ply2] = canTalk and (deadv or ply2:Alive())
                    DrpCanHear[ply2][ply1] = canTalk and (deadv or ply1:Alive()) -- Take advantage of the symmetry
                end
            end
        end
    end
end)

hook.Add("PlayerDisconnect", "DarkRPCanHear", function(ply)
    DrpCanHear[ply] = nil
end)

function GM:PlayerCanHearPlayersVoice(listener, talker)
    if not deadv and not talker:Alive() then return false end
    return DrpCanHear[listener][talker] == true, true
end

function GM:CanTool(ply, trace, mode)
    if not self.Sandbox.CanTool(self, ply, trace, mode) then return false end

    local ent = trace.Entity
    if IsValid(ent) then
        if ent.onlyremover then
            if mode == "remover" then
                return ply:IsAdmin() or ply:IsSuperAdmin()
            else
                return false
            end
        end

        if ent.nodupe and (mode == "weld" or
                    mode == "weld_ez" or
                    mode == "spawner" or
                    mode == "duplicator" or
                    mode == "adv_duplicator") then
            return false
        end

        if ent:IsVehicle() and mode == "nocollide" and not GAMEMODE.Config.allowvnocollide then
            return false
        end
    end
    return true
end

function GM:CanPlayerSuicide(ply)
    if ply.IsSleeping then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "suicide", ""))
        return false
    end

    local jobTable = ply:getJobTable()
    if jobTable.CanPlayerSuicide then
        return jobTable.CanPlayerSuicide(ply)
    end
    return true
end

function GM:CanDrive(ply, ent)
    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("drive_disabled"))
    return false -- Disabled until people can't minge with it anymore
end

function GM:CanProperty(ply, property, ent)
    if self.Config.allowedProperties[property] and ent:CPPICanTool(ply, "remover") then
        return true
    end

    if property == "persist" and ply:IsSuperAdmin() then
        return true
    end
    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("property_disabled"))
    return false -- Disabled until antiminge measure is found
end

function GM:PlayerShouldTaunt(ply, actid)
    return GAMEMODE.Config.allowActs
end

function GM:DoPlayerDeath(ply, attacker, dmginfo, ...)
    local weapon = ply:GetActiveWeapon()
    local canDrop = hook.Call("canDropWeapon", self, ply, weapon)

    if (GAMEMODE.Config.dropweapondeath or ply.dropWeaponOnDeath) and weapon:IsValid() and canDrop then
        ply:dropDRPWeapon(weapon)
    end
    self.Sandbox.DoPlayerDeath(self, ply, attacker, dmginfo, ...)
end

function GM:PlayerDeath(ply, weapon, killer)
    local jobTable = ply:getJobTable()
    if jobTable.PlayerDeath then
        jobTable.PlayerDeath(ply, weapon, killer)
    end

    if GAMEMODE.Config.deathblack and not ply.blackScreen then
        ply.blackScreen = true
        SendUserMessage("blackScreen", ply, true)
    end

    if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end

    if GAMEMODE.Config.showdeaths then
        self.Sandbox.PlayerDeath(self, ply, weapon, killer)
    end

    ply:Extinguish()

    ply:ExitVehicle()

    ply.NextSpawnTime = CurTime() + math.Clamp(GAMEMODE.Config.respawntime, 0, 10)
    ply.DeathPos = ply:GetPos()

    if GAMEMODE.Config.dropmoneyondeath then
        local amount = GAMEMODE.Config.deathfee
        if not ply:canAfford(GAMEMODE.Config.deathfee) then
            amount = ply:getDarkRPVar("money")
        end

        if amount > 0 then
            ply:addMoney(-amount)
            DarkRP.createMoneyBag(ply:GetPos(), amount)
        end
    end

    if IsValid(ply) and (ply ~= killer or ply.Slayed) then
        ply.DeathPos = nil
        ply.Slayed = false
    end

    ply.ConfiscatedWeapons = nil

    local KillerName = (killer:IsPlayer() and killer:Nick()) or tostring(killer)
    local WeaponName = IsValid(weapon) and ((weapon:IsPlayer() and weapon:GetActiveWeapon():IsValid() and weapon:GetActiveWeapon():GetClass()) or weapon:GetClass()) or "unknown"

    if killer == ply then
        KillerName = "Himself"
        WeaponName = "suicide trick"
    end

    DarkRP.log(ply:Nick() .. " was killed by " .. KillerName .. " with a " .. WeaponName, Color(255, 190, 0))
end

local adminCopWeapons = {
    ["stunstick"] = true,
    ["weaponchecker"] = true,
}
function GM:PlayerCanPickupWeapon(ply, weapon)
    if weapon.PlayerUse == false then return false end
    local weaponClass = weapon:GetClass()
    if ply:IsAdmin() and GAMEMODE.Config.AdminsCopWeapons and adminCopWeapons[weaponClass] then return true end

    local jobTable = ply:getJobTable()
    if jobTable.PlayerCanPickupWeapon then
        local val = jobTable.PlayerCanPickupWeapon(ply, weapon)

        return val == nil or val
    end

    return true
end

function GM:PlayerSetModel(ply)
    local jobTable = ply:getJobTable()

    -- Invalid job, return to Sandbox behaviour
    if not jobTable then return self.Sandbox.PlayerSetModel(ply) end

    if jobTable.PlayerSetModel then
        local model = jobTable.PlayerSetModel(ply)
        if model then ply:SetModel(model) return end
    end

    local EndModel = ""
    if GAMEMODE.Config.enforceplayermodel then
        if istable(jobTable.model) then
            local ChosenModel = string.lower(ply:getPreferredModel(ply:Team()) or "")

            local found
            for _, Models in pairs(jobTable.model) do
                if ChosenModel == string.lower(Models) then
                    EndModel = Models
                    found = true
                    break
                end
            end

            if not found then
                EndModel = jobTable.model[math.random(#jobTable.model)]
            end
        else
            EndModel = jobTable.model
        end

        ply:SetModel(EndModel)
    else
        local cl_playermodel = ply:GetInfo("cl_playermodel")
        local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
        ply:SetModel(ply:getPreferredModel(ply:Team()) or modelname)
    end

    self.Sandbox.PlayerSetModel(self, ply)

    ply:SetupHands()
end

local function initPlayer(ply)
    ply:updateJob(team.GetName(GAMEMODE.DefaultTeam))
    ply:setSelfDarkRPVar("salary", DarkRP.retrieveSalary(ply))
    ply.LastJob = nil
    ply.Ownedz = {}
    ply:SetTeam(GAMEMODE.DefaultTeam)
    ply.DarkRPInitialised = true
end

local function restoreReconnectedEnts(ply)
    local sid = ply:SteamID64()
    if not queuedForRemoval[sid] then return end

    timer.Remove("DarkRP_removeDisconnected_" .. sid)

    for _, e in pairs(queuedForRemoval[sid]) do
        if not IsValid(e) then continue end

        e.SID = ply.SID

        if e.Setowning_ent then
            e:Setowning_ent(ply)
        end

        -- Some entities (e.g. vehicles) have an SID, but do not have a DarkRPItem
        if e.DarkRPItem then
            ply:addCustomEntity(e.DarkRPItem)
        end
    end

    queuedForRemoval[sid] = nil
end

function GM:PlayerInitialSpawn(ply)
    self.Sandbox.PlayerInitialSpawn(self, ply)
    DrpCanHear[ply] = {}

    local sid = ply:SteamID()
    DarkRP.log(ply:Nick() .. " (" .. sid .. ") has joined the game", Color(0, 130, 255))
    ply:setDarkRPVarsAttribute()
    ply:restorePlayerData()
    initPlayer(ply)
    ply.SID = ply:UserID()

    timer.Simple(1, function()
        if not IsValid(ply) then return end
        local group = GAMEMODE.Config.DefaultPlayerGroups[sid]
        if group then
            ply:SetUserGroup(group)
        end
    end)
    
    local timerid = ply:SteamID64() .. "jobtimer"
    timer.Create(timerid, GAMEMODE.Config.paydelay, 0, function()
        if not IsValid(ply) then
            timer.Remove(timerid)
            return
        end
        ply:payDay()
    end)

    restoreReconnectedEnts(ply)
end

function GM:PlayerSelectSpawn(ply)
    local spawn = self.Sandbox.PlayerSelectSpawn(self, ply)

    local jobTable = ply:getJobTable()
    if jobTable.PlayerSelectSpawn then
        jobTable.PlayerSelectSpawn(ply, spawn)
    end

    local POS
    if spawn and spawn.GetPos then
        POS = spawn:GetPos()
    else
        POS = ply:GetPos()
    end

    local CustomSpawnPos = DarkRP.retrieveTeamSpawnPos(ply:Team())
    if GAMEMODE.Config.customspawns and CustomSpawnPos and next(CustomSpawnPos) ~= nil then
        POS = CustomSpawnPos[math.random(1, #CustomSpawnPos)]
    end

    -- Spawn where died in certain cases
    if GAMEMODE.Config.strictsuicide and ply.DeathPos then
        POS = ply.DeathPos
    end

    -- Make sure the player doesn't get stuck in something

    local _, hull = ply:GetHull()

    POS = DarkRP.findEmptyPos(POS, {ply}, 600, 30, hull)

    return spawn, POS
end

local oldPlyColor
local function disableBabyGod(ply)
    if not IsValid(ply) or not ply.Babygod then return end

    ply.Babygod = nil
    ply:SetRenderMode(RENDERMODE_NORMAL)
    ply:GodDisable()

    -- Don't reinstate the SetColor function
    -- if there are still players who are babygodded
    local reinstateOldColor = true

    for _, p in ipairs(player.GetAll()) do
        reinstateOldColor = reinstateOldColor and p.Babygod == nil
    end

    if reinstateOldColor then
        entMeta.SetColor = oldPlyColor
        oldPlyColor = nil
    end

    ply:SetColor(ply.babyGodColor or Color(255, 255, 255, 255))

    ply.babyGodColor = nil
end

local function enableBabyGod(ply)
    timer.Remove(ply:EntIndex() .. "babygod")

    ply.Babygod = true
    ply:GodEnable()
    ply.babyGodColor = ply:GetColor()
    ply:SetRenderMode(RENDERMODE_TRANSALPHA)

    if not oldPlyColor then
        oldPlyColor = entMeta.SetColor
        entMeta.SetColor = function(p, c, ...)
            if not p.Babygod then return oldPlyColor(p, c, ...) end

            p.babyGodColor = c
            oldPlyColor(p, Color(c.r, c.g, c.b, 100))
        end
    end

    ply:SetColor(ply.babyGodColor)
    timer.Create(ply:EntIndex() .. "babygod", GAMEMODE.Config.babygodtime or 0, 1, fp{disableBabyGod, ply})
end

function GM:PlayerSpawn(ply)
    if not ply.DarkRPInitialised then
        DarkRP.errorNoHalt(string.format("DarkRP was unable to introduce player \"%s\" to the game.", IsValid(ply) and ply:Nick() or "unknown"), 1)
    end

    ply:CrosshairEnable()
    ply:UnSpectate()
    ply:Extinguish()
    if ply.blackScreen then
        ply.blackScreen = false
        SendUserMessage("blackScreen", ply, false)
    end

    if GAMEMODE.Config.babygod and not ply.IsSleeping and not ply.Babygod then
        enableBabyGod(ply)
    end
    ply.IsSleeping = false
    for i=0,2 do
        local vm = ply:GetViewModel(i)

        if IsValid(vm) then
            vm:Extinguish()
        end
    end

    local jobTable = ply:getJobTable()

    player_manager.SetPlayerClass(ply, jobTable.playerClass or "player_darkrp")

    ply:applyPlayerClassVars(true)

    player_manager.RunClass(ply, "Spawn")

    hook.Call("PlayerLoadout", self, ply)
    hook.Call("PlayerSetModel", self, ply)

    local ent, pos = hook.Call("PlayerSelectSpawn", self, ply)
    ply:SetPos(pos or ent:GetPos())

    if jobTable.PlayerSpawn then
        jobTable.PlayerSpawn(ply)
    end

    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") spawned")
end

function GM:PlayerLoadout(ply)
    self.Sandbox.PlayerLoadout(self, ply)

    local jobTable = ply:getJobTable()

    for _, v in pairs(jobTable.weapons or {}) do
        ply:Give(v)
    end

    if jobTable.PlayerLoadout then
        local val = jobTable.PlayerLoadout(ply)
        if val == true then
            ply:SwitchToDefaultWeapon()
            return
        end
    end

    if jobTable.ammo then
        for k, v in pairs(jobTable.ammo) do
            ply:SetAmmo(v, k)
        end
    end

    for _, v in pairs(self.Config.DefaultWeapons) do
        ply:Give(v)
    end

    CAMI.PlayerHasAccess(ply, "DarkRP_GetAdminWeapons", function(access)
        if not access or not IsValid(ply) then return end

        for _, v in pairs(GAMEMODE.Config.AdminWeapons) do
            ply:Give(v)
        end

        if not GAMEMODE.Config.AdminsCopWeapons then return end

        ply:Give("stunstick")
        ply:Give("weaponchecker")
    end)

    ply:SwitchToDefaultWeapon()
end

--[[---------------------------------------------------------------------------
Remove with a delay if the player doesn't rejoin before the timer has run out
---------------------------------------------------------------------------]]
local function removeDelayed(entList, ply)
    local removedelay = GAMEMODE.Config.entremovedelay

    if removedelay <= 0 then
        for _, e in pairs(entList) do
            SafeRemoveEntity(e)
        end

        return
    end

    local sid = ply:SteamID64()
    queuedForRemoval[sid] = entList

    timer.Create("DarkRP_removeDisconnected_" .. sid, removedelay, 1, function()
        for _, e in pairs(queuedForRemoval[sid] or {}) do
            SafeRemoveEntity(e)
        end

        queuedForRemoval[sid] = nil
    end)
end

-- Collect entities that are to be removed
local function collectRemoveEntities(ply)
    if not GAMEMODE.Config.removeondisconnect then return {} end

    local collect = {}
    -- Get the classes of entities to remove
    local remClasses = {}
    for _, customEnt in pairs(DarkRPEntities) do
        remClasses[string.lower(customEnt.ent)] = true
    end

    local sid = ply.SID
    for _, v in ipairs(ents.GetAll()) do
        if v.SID ~= sid or not v:IsVehicle() and not remClasses[string.lower(v:GetClass() or "")] then continue end

        table.insert(collect, v)
    end

    return collect
end

function GM:PlayerDisconnected(ply)
    self.Sandbox.PlayerDisconnected(self, ply)
    timer.Remove(ply:SteamID64() .. "jobtimer")

    local isMayor = ply:isMayor()

    local remList = collectRemoveEntities(ply)
    removeDelayed(remList, ply)

    if IsValid(ply.SleepRagdoll) then
        ply.SleepRagdoll:Remove()
    end

    ply:keysUnOwnAll()
    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") disconnected", Color(0, 130, 255))

    local jobTable = ply:getJobTable()
    if jobTable.PlayerDisconnected then
        jobTable.PlayerDisconnected(ply)
    end
end

function GM:GetFallDamage( ply, flFallSpeed )
    if GetConVar("mp_falldamage"):GetBool() or GAMEMODE.Config.realisticfalldamage then
        if GAMEMODE.Config.falldamagedamper then return flFallSpeed / GAMEMODE.Config.falldamagedamper else return flFallSpeed / 15 end
    else
        if GAMEMODE.Config.falldamageamount then return GAMEMODE.Config.falldamageamount else return 10 end
    end
end

function GM:InitPostEntity()
    self.InitPostEntityCalled = true

    local physData = physenv.GetPerformanceSettings()
    physData.MaxVelocity = 2000
    physData.MaxAngularVelocity = 3636

    physenv.SetPerformanceSettings(physData)

    game.ConsoleCommand("physgun_DampingFactor 0.9\n")
    game.ConsoleCommand("sv_sticktoground 0\n")
    game.ConsoleCommand("sv_airaccelerate 1000\n")
    game.ConsoleCommand("sv_alltalk 0\n")

    if GAMEMODE.Config.unlockdoorsonstart then
        for _, v in ipairs(ents.GetAll()) do
            if not v:isDoor() then continue end
            v:Fire("unlock", "", 0)
        end
    end
end
timer.Simple(0.1, function()
    if not GAMEMODE.InitPostEntityCalled then
        GAMEMODE:InitPostEntity()
    end
end)

function GM:loadCustomDarkRPItems()
    if not GAMEMODE.DefaultTeam or not RPExtraTeams[GAMEMODE.DefaultTeam] then
        GAMEMODE.DefaultTeam = next(RPExtraTeams)
        DarkRP.error("GAMEMODE.DefaultTeam is not set to an existing job.", 1)
    end
end

function GM:PlayerLeaveVehicle(ply, vehicle)
    if GAMEMODE.Config.autovehiclelock and vehicle:isKeysOwnedBy(ply) then
        vehicle:keysLock()
    end
    self.Sandbox.PlayerLeaveVehicle(self, ply, vehicle)
end

local function ClearDecals()
    if GAMEMODE.Config.decalcleaner then
        for _, p in ipairs(player.GetAll()) do
            p:ConCommand("r_cleardecals")
        end
    end
end
timer.Create("RP_DecalCleaner", GM.Config.decaltimer, 0, ClearDecals)

function GM:PlayerSpray()
    return not GAMEMODE.Config.allowsprays
end
