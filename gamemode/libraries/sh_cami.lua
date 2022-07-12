--[[
CAMI - Common Admin Mod Interface.
Docs: https://github.com/FPtje/DarkRP/blob/master/gamemode/libraries/sh_cami.lua´
Specification: https://docs.google.com/document/d/1QIRVcAgZfAYf1aBl_dNV_ewR6P25wze2KmUVzlbFgMI
]]

-- Version number in YearMonthDay format.
local version = 20190102

if CAMI and CAMI.Version >= version then return end

CAMI = CAMI or {}
CAMI.Version = version

local usergroups = CAMI.GetUsergroups and CAMI.GetUsergroups() or {
    user = {
        Name = "user",
        Inherits = "user"
    },
    admin = {
        Name = "admin",
        Inherits = "user"
    },
    superadmin = {
        Name = "superadmin",
        Inherits = "admin"
    }
}

local privileges = CAMI.GetPrivileges and CAMI.GetPrivileges() or {}

function CAMI.RegisterUsergroup(usergroup, source)
    usergroups[usergroup.Name] = usergroup

    hook.Call("CAMI.OnUsergroupRegistered", nil, usergroup, source)
    return usergroup
end

function CAMI.UnregisterUsergroup(usergroupName, source)
    if not usergroups[usergroupName] then return false end

    local usergroup = usergroups[usergroupName]
    usergroups[usergroupName] = nil

    hook.Call("CAMI.OnUsergroupUnregistered", nil, usergroup, source)

    return true
end


function CAMI.GetUsergroups()
    return usergroups
end


function CAMI.GetUsergroup(usergroupName)
    return usergroups[usergroupName]
end

function CAMI.UsergroupInherits(usergroupName1, usergroupName2)
    repeat
        if usergroupName1 == usergroupName2 then return true end

        usergroupName1 = usergroups[usergroupName1] and
                         usergroups[usergroupName1].Inherits or
                         usergroupName1
    until not usergroups[usergroupName1] or
          usergroups[usergroupName1].Inherits == usergroupName1

    -- One can only be sure the usergroup inherits from user if the
    -- usergroup isn't registered.
    return usergroupName1 == usergroupName2 or usergroupName2 == "user"
end

function CAMI.InheritanceRoot(usergroupName)
    if not usergroups[usergroupName] then return end

    local inherits = usergroups[usergroupName].Inherits
    while inherits ~= usergroups[usergroupName].Inherits do
        usergroupName = usergroups[usergroupName].Inherits
    end

    return usergroupName
end

function CAMI.RegisterPrivilege(privilege)
    privileges[privilege.Name] = privilege

    hook.Call("CAMI.OnPrivilegeRegistered", nil, privilege)

    return privilege
end

function CAMI.UnregisterPrivilege(privilegeName)
    if not privileges[privilegeName] then return false end

    local privilege = privileges[privilegeName]
    privileges[privilegeName] = nil

    hook.Call("CAMI.OnPrivilegeUnregistered", nil, privilege)

    return true
end

function CAMI.GetPrivileges()
    return privileges
end

function CAMI.GetPrivilege(privilegeName)
    return privileges[privilegeName]
end


-- Default access handler
local defaultAccessHandler = {["CAMI.PlayerHasAccess"] =
    function(_, actorPly, privilegeName, callback, _, extraInfoTbl)
        -- The server always has access in the fallback
        if not IsValid(actorPly) then return callback(true, "Fallback.") end

        local priv = privileges[privilegeName]

        local fallback = extraInfoTbl and (
            not extraInfoTbl.Fallback and actorPly:IsAdmin() or
            extraInfoTbl.Fallback == "user" and true or
            extraInfoTbl.Fallback == "admin" and actorPly:IsAdmin() or
            extraInfoTbl.Fallback == "superadmin" and actorPly:IsSuperAdmin())


        if not priv then return callback(fallback, "Fallback.") end

        callback(
            priv.MinAccess == "user" or
            priv.MinAccess == "admin" and actorPly:IsAdmin() or
            priv.MinAccess == "superadmin" and actorPly:IsSuperAdmin()
            , "Fallback.")
    end,
    ["CAMI.SteamIDHasAccess"] =
    function(_, _, _, callback)
        callback(false, "No information available.")
    end
}
function CAMI.PlayerHasAccess(actorPly, privilegeName, callback, targetPly,
extraInfoTbl)
    local hasAccess, reason = nil, nil
    local callback_ = callback or function(hA, r) hasAccess, reason = hA, r end

    hook.Call("CAMI.PlayerHasAccess", defaultAccessHandler, actorPly,
        privilegeName, callback_, targetPly, extraInfoTbl)

    if callback ~= nil then return end

    if hasAccess == nil then
        local err = [[The function CAMI.PlayerHasAccess was used to find out
        whether Player %s has privilege "%s", but an admin mod did not give an
        immediate answer!]]
        error(string.format(err,
            actorPly:IsPlayer() and actorPly:Nick() or tostring(actorPly),
            privilegeName))
    end

    return hasAccess, reason
end


function CAMI.GetPlayersWithAccess(privilegeName, callback, targetPly,
extraInfoTbl)
    local allowedPlys = {}
    local allPlys = player.GetAll()
    local countdown = #allPlys

    local function onResult(ply, hasAccess, _)
        countdown = countdown - 1

        if hasAccess then table.insert(allowedPlys, ply) end
        if countdown == 0 then callback(allowedPlys) end
    end

    for _, ply in ipairs(allPlys) do
        CAMI.PlayerHasAccess(ply, privilegeName,
            function(...) onResult(ply, ...) end,
            targetPly, extraInfoTbl)
    end
end


function CAMI.SteamIDHasAccess(actorSteam, privilegeName, callback,
targetSteam, extraInfoTbl)
    hook.Call("CAMI.SteamIDHasAccess", defaultAccessHandler, actorSteam,
        privilegeName, callback, targetSteam, extraInfoTbl)
end


function CAMI.SignalUserGroupChanged(ply, old, new, source)
    hook.Call("CAMI.PlayerUsergroupChanged", nil, ply, old, new, source)
end


function CAMI.SignalSteamIDUserGroupChanged(steamId, old, new, source)
    hook.Call("CAMI.SteamIDUsergroupChanged", nil, steamId, old, new, source)
end
