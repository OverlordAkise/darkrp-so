--[[---------------------------------------------------------------------------
Loading
---------------------------------------------------------------------------]]
local teamSpawns = {}
local function onDBInitialized()
    local map = MySQLite.SQLStr(string.lower(game.GetMap()))
    MySQLite.query("SELECT * FROM darkrp_position NATURAL JOIN darkrp_jobspawn WHERE map = " .. map .. ";", function(data)
        teamSpawns = data or {}
    end)
end
hook.Add("DarkRPDBInitialized", "GetPositions", onDBInitialized)

function DarkRP.storeTeamSpawnPos(t, pos)
    local map = string.lower(game.GetMap())
    local teamcmd = RPExtraTeams[t].command


    DarkRP.removeTeamSpawnPos(t, function()
        MySQLite.query([[INSERT INTO darkrp_position(map, type, x, y, z) VALUES(]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
            , function()
            MySQLite.queryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
                if not id then return end
                MySQLite.query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. MySQLite.SQLStr(teamcmd) .. [[);]])
                table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], teamcmd = teamcmd})
            end)
        end)
    end)
end

function DarkRP.addTeamSpawnPos(t, pos)
    local map = string.lower(game.GetMap())
    local teamcmd = RPExtraTeams[t].command

    MySQLite.query([[INSERT INTO darkrp_position(map, type, x, y, z) VALUES(]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
        , function()
        MySQLite.queryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
            if isbool(id) then return end
            MySQLite.query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. MySQLite.SQLStr(teamcmd) .. [[);]])
            table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], teamcmd = teamcmd})
        end)
    end)
end

function DarkRP.removeTeamSpawnPos(t, callback)
    local map = string.lower(game.GetMap())
    local teamcmd = RPExtraTeams[tonumber(t)].command

    for k, v in pairs(teamSpawns) do
        if v.teamcmd == teamcmd then
            teamSpawns[k] = nil
        end
    end

    MySQLite.query([[SELECT darkrp_position.id FROM darkrp_position
        NATURAL JOIN darkrp_jobspawn
        WHERE map = ]] .. MySQLite.SQLStr(map) .. [[
        AND teamcmd = ]] .. MySQLite.SQLStr(teamcmd) .. [[;]], function(data)

        MySQLite.begin()
        for _, v in ipairs(data or {}) do
            MySQLite.query([[DELETE FROM darkrp_position WHERE id = ]] .. v.id .. [[;]])
            MySQLite.query([[DELETE FROM darkrp_jobspawn WHERE id = ]] .. v.id .. [[;]])
        end
        MySQLite.commit(callback)
    end)
end

function DarkRP.retrieveTeamSpawnPos(t)
    local isTeam = function(tbl) return RPExtraTeams[t].command == tbl.teamcmd end
    local getPos = function(tbl) return Vector(tonumber(tbl.x), tonumber(tbl.y), tonumber(tbl.z)) end

    return table.ClearKeys(fn.Map(getPos, fn.Filter(isTeam, teamSpawns)))
end
