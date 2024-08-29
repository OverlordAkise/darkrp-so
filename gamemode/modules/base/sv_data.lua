
local setUpNonOwnableDoors,
    setUpTeamOwnableDoors,
    setUpGroupDoors,
    updateDBSchema

--Database initialize
--Original: https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/sv_data.lua#L12
function DarkRP.initDatabase()
    MySQLite.begin()
    local is_mysql = MySQLite.isMySQL()
    local AUTOINCREMENT = is_mysql and "AUTO_INCREMENT" or "AUTOINCREMENT"
    -- Race conditions could occur if the queries are executed simultaneously
    MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS darkrp_position(id INTEGER NOT NULL PRIMARY KEY "..AUTOINCREMENT..", map VARCHAR(45) NOT NULL, type CHAR(1) NOT NULL, x INTEGER NOT NULL, y INTEGER NOT NULL, z INTEGER NOT NULL);")
    MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS darkrp_jobspawn(id INTEGER NOT NULL PRIMARY KEY REFERENCES darkrp_position(id) ON UPDATE CASCADE ON DELETE CASCADE, teamcmd VARCHAR(255) NOT NULL);")
    MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS playerinformation(uid BIGINT NOT NULL, steamID VARCHAR(50) NOT NULL PRIMARY KEY);")
    MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS darkrp_player(uid BIGINT NOT NULL PRIMARY KEY, rpname VARCHAR(45), salary INTEGER NOT NULL DEFAULT 45, wallet BIGINT NOT NULL);")
    MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS darkrp_door(idx INTEGER NOT NULL, map VARCHAR(45) NOT NULL, title VARCHAR(25), isLocked BOOLEAN, isDisabled BOOLEAN NOT NULL DEFAULT FALSE, PRIMARY KEY(idx, map));")
    MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS darkrp_doorjobs(idx INTEGER NOT NULL, map VARCHAR(45) NOT NULL, job VARCHAR(255) NOT NULL, PRIMARY KEY(idx, map, job));")
    MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS darkrp_doorgroups( idx INTEGER NOT NULL, map VARCHAR(45) NOT NULL, doorgroup VARCHAR(100) NOT NULL, PRIMARY KEY(idx, map));")
    MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS darkrp_dbversion(version INTEGER NOT NULL PRIMARY KEY)")
    MySQLite.queueQuery("REPLACE INTO darkrp_dbversion VALUES(20211228)")

    MySQLite.commit(function()
        setUpNonOwnableDoors()
        setUpTeamOwnableDoors()
        setUpGroupDoors()
        if MySQLite.isMySQL() then --if mysql loads slower than players joining we will load it again here
            for _, v in ipairs(player.GetAll()) do
                DarkRP.offlinePlayerData(v:SteamID(), function(data)
                    local Data = data and data[1]
                    if not IsValid(v) or not Data then return end
                    v:setDarkRPVar("rpname", Data.rpname)
                    v:setSelfDarkRPVar("salary", Data.salary)
                    v:setDarkRPVar("money", Data.wallet)
                end)
            end
        end
        hook.Call("DarkRPDBInitialized")
    end)
end

--Players
function DarkRP.storeRPName(ply, name)
    if not name or string.len(name) < 2 then return end
    hook.Call("onPlayerChangedName", nil, ply, ply:getDarkRPVar("rpname"), name)
    ply:setDarkRPVar("rpname", name)
    MySQLite.query("UPDATE darkrp_player SET rpname="..MySQLite.SQLStr(name).." WHERE UID="..ply:SteamID64())
end

function DarkRP.retrieveRPNames(name, callback)
    MySQLite.query("SELECT COUNT(*) AS count FROM darkrp_player WHERE rpname = " .. MySQLite.SQLStr(name) .. ";", function(r)
        callback(tonumber(r[1].count) > 0)
    end)
end

function DarkRP.offlinePlayerData(steamid, callback, failed)
    local sid64 = util.SteamIDTo64(steamid)
    MySQLite.query(string.format("REPLACE INTO playerinformation VALUES(%s, %s);", MySQLite.SQLStr(sid64), MySQLite.SQLStr(steamid)), nil, failed)
    MySQLite.query("SELECT rpname, wallet, salary FROM darkrp_player WHERE uid="..sid64, function(data, ...)
        return callback and callback(data, ...)
    end, failed)
end

function DarkRP.retrievePlayerData(ply, callback, failed, attempts, err)
    attempts = attempts or 0
    if attempts > 3 then return failed(err) end
    DarkRP.offlinePlayerData(ply:SteamID(), callback, function(sqlErr)
        if not IsValid(ply) then return end
        DarkRP.retrievePlayerData(ply, callback, failed, attempts + 1, sqlErr)
    end)
end

function DarkRP.createPlayerData(ply, name, wallet, salary)
    MySQLite.query("REPLACE INTO darkrp_player VALUES("..ply:SteamID64()..","..MySQLite.SQLStr(name)..","..salary..","..wallet..");")
end

function DarkRP.storeMoney(ply, amount)
    if not isnumber(amount) or amount < 0 or amount >= 1 / 0 then return end
    MySQLite.query("UPDATE darkrp_player SET wallet="..amount.." WHERE uid="..ply:SteamID64())
end

function DarkRP.storeOfflineMoney(sid64, amount)
    if isnumber(sid64) or isstring(sid64) and string.len(sid64) < 17 then
        ErrorNoHaltWithStack("ERROR: DarkRP.storeOfflineMoney received a UniqueID instead of SteamID64! Not saving money...")
        return
    end
    MySQLite.query("UPDATE darkrp_player SET wallet=".. amount .." WHERE uid="..sid64)
end

concommand.Add("rp_resetallmoney", function(ply, cmd, args)
    if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then return end
    MySQLite.query("UPDATE darkrp_player SET wallet=" .. GAMEMODE.Config.startingmoney)
    for _, v in ipairs(player.GetAll()) do
        v:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
    end
    if ply:IsPlayer() then
        DarkRP.notifyAll(0, 4, DarkRP.getPhrase("reset_money", ply:Nick()))
    else
        DarkRP.notifyAll(0, 4, DarkRP.getPhrase("reset_money", "Console"))
    end
end)

function DarkRP.storeSalary(ply, amount)
    ply:setSelfDarkRPVar("salary", math.floor(amount))
    return amount
end

function DarkRP.retrieveSalary(ply, callback)
    local val = ply:getJobTable() and ply:getJobTable().salary or
        RPExtraTeams[GAMEMODE.DefaultTeam].salary or
        (GM or GAMEMODE).Config.normalsalary
        
    if callback then callback(val) end
    return val
end

--Players
local meta = FindMetaTable("Player")
function meta:restorePlayerData()
    self.DarkRPUnInitialized = true

    DarkRP.retrievePlayerData(self, function(data)
        if not IsValid(self) then return end

        self.DarkRPUnInitialized = nil

        local info = data and data[1] or {}
        if not info.rpname or info.rpname == "NULL" then info.rpname = string.gsub(self:SteamName(), "\\\"", "\"") end

        info.wallet = info.wallet or GAMEMODE.Config.startingmoney
        info.salary = DarkRP.retrieveSalary(self)
        self:setDarkRPVar("money", tonumber(info.wallet))
        self:setSelfDarkRPVar("salary", tonumber(info.salary))
        self:setDarkRPVar("rpname", info.rpname)

        if not data then
            info = hook.Call("onPlayerFirstJoined", nil, self, info) or info
            DarkRP.createPlayerData(self, info.rpname, info.wallet, info.salary)
        end
    end, function(err) -- Retrieving data failed, go on without it
        if not IsValid(self) then return end
        self.DarkRPUnInitialized = true -- no information should be saved from here, or the playerdata might be reset

        self:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
        self:setSelfDarkRPVar("salary", DarkRP.retrieveSalary(self))
        local name = string.gsub(self:SteamName(), "\\\"", "\"")
        self:setDarkRPVar("rpname", name)

        self.DarkRPDataRetrievalFailed = true -- marker on the player that says shit is fucked
        DarkRP.error("Failed to retrieve player information from the database. ", nil, {"This means your database or the connection to your database is fucked.", "This is the error given by the database:\n\t\t" .. tostring(err)})
    end)
end

--Doors
function DarkRP.storeDoorData(ent)
    if not ent:CreatedByMap() then return end
    local title = ent:getKeysTitle()
    MySQLite.query([[REPLACE INTO darkrp_door VALUES(]] .. ent:doorIndex() .. [[, ]] .. MySQLite.SQLStr(string.lower(game.GetMap())) .. [[, ]] .. (title and MySQLite.SQLStr(title) or "NULL") .. [[, ]] .. "NULL" .. [[, ]] .. (ent:getKeysNonOwnable() and 1 or 0) .. [[);]])
end

function setUpNonOwnableDoors()
    --TODO: Making all doors unownable is only for SCPRP, maybe change this to make it configurable
    for k,v in ipairs(ents.GetAll()) do
        if ownableDoors[v:GetClass()] then
            v:setKeysNonOwnable(true)
        end
    end
    
    MySQLite.query("SELECT idx, title, isLocked, isDisabled FROM darkrp_door WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
        if not r then return end

        for _, row in pairs(r) do
            local e = DarkRP.doorIndexToEnt(tonumber(row.idx))

            if not IsValid(e) then continue end
            if e:isKeysOwnable() then
                e:setKeysNonOwnable(tobool(row.isDisabled))
                if row.isLocked and row.isLocked ~= "NULL" then
                    e:Fire((tobool(row.isLocked) and "" or "un") .. "lock", "", 0)
                end
                e:setKeysTitle(row.title ~= "NULL" and row.title or nil)
            end
        end
    end)
end

local keyValueActions = {
    ["DarkRPNonOwnable"]  = function(ent, val) ent:setKeysNonOwnable(tobool(val)) end,
    ["DarkRPTitle"]       = function(ent, val) ent:setKeysTitle(val) end,
    ["DarkRPDoorGroup"]   = function(ent, val) if RPExtraTeamDoors[val] then ent:setDoorGroup(val) end end,
    ["DarkRPCanLockpick"] = function(ent, val) ent.DarkRPCanLockpick = tobool(val) end
}

hook.Add("EntityKeyValue", "darkrp_doors", function(ent,key,value)
    if not ent:isDoor() then return end
    if keyValueActions[key] then
        keyValueActions[key](ent, value)
    end
end)

function DarkRP.storeTeamDoorOwnability(ent)
    if not ent:CreatedByMap() then return end
    local map = string.lower(game.GetMap())

    MySQLite.query("DELETE FROM darkrp_doorjobs WHERE idx = " .. ent:doorIndex() .. " AND map = " .. MySQLite.SQLStr(map) .. ";")
    for k in pairs(ent:getKeysDoorTeams() or {}) do
        MySQLite.query("INSERT INTO darkrp_doorjobs VALUES(" .. ent:doorIndex() .. ", " .. MySQLite.SQLStr(map) .. ", " .. MySQLite.SQLStr(RPExtraTeams[k].command) .. ");")
    end
end

function setUpTeamOwnableDoors()
    MySQLite.query("SELECT idx, job FROM darkrp_doorjobs WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
        if not r then return end
        local map = string.lower(game.GetMap())

        for _, row in pairs(r) do
            row.idx = tonumber(row.idx)

            local e = DarkRP.doorIndexToEnt(row.idx)
            if not IsValid(e) then continue end

            local _, job = DarkRP.getJobByCommand(row.job)

            if job then
                e:addKeysDoorTeam(job)
            else
                print(Format("can't find job %s for door %d, removing from database",row.job, row.idx))
                MySQLite.query(Format("DELETE FROM darkrp_doorjobs WHERE idx=%d AND map=%s AND job=%s;",row.idx, MySQLite.SQLStr(map), MySQLite.SQLStr(row.job)))
            end
        end
    end)
end

function DarkRP.storeDoorGroup(ent, group)
    if not ent:CreatedByMap() then return end
    local map = MySQLite.SQLStr(string.lower(game.GetMap()))
    local index = ent:doorIndex()
    if group == "" or not group then
        MySQLite.query("DELETE FROM darkrp_doorgroups WHERE map="..map.." AND idx="..index)
        return
    end
    MySQLite.query("REPLACE INTO darkrp_doorgroups VALUES("..index..","..map..","..MySQLite.SQLStr(group)..");");
end

function setUpGroupDoors()
    MySQLite.query("SELECT idx, doorgroup FROM darkrp_doorgroups WHERE map="..MySQLite.SQLStr(string.lower(game.GetMap())), function(data)
        if not data then return end
        for _, row in pairs(data) do
            local ent = DarkRP.doorIndexToEnt(tonumber(row.idx))
            if not IsValid(ent) or not ent:isKeysOwnable() then
                continue
            end
            if not RPExtraTeamDoorIDs[row.doorgroup] then continue end
            ent:setDoorGroup(row.doorgroup)
        end
    end)
end

hook.Add("PostCleanupMap", "DarkRP.hooks", function()
    setUpNonOwnableDoors()
    setUpTeamOwnableDoors()
    setUpGroupDoors()
end)
