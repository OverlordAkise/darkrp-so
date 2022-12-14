-- Shared part

function DarkRP.getAvailableVehicles()
    local vehicles = list.Get("Vehicles")
    for _, v in pairs(list.Get("SCarsList")) do
        vehicles[v.PrintName] = {
            Name = v.PrintName,
            Class = v.ClassName,
            Model = v.CarModel
        }
    end

    return vehicles
end

local function argError(Val, iArg, sType)
    error(string.format("bad argument #%u to '%s' (%s expected, got %s)", iArg, debug.getinfo(2, "n").name, sType, type(Val)), 3)
end

if not DarkRP.disabledDefaults["workarounds"]["os.date() Windows crash"] and system.IsWindows() then
    local osdate = os.date
    local replace = function(txt)
        if txt == "%%" then return txt end -- Edge case, %% is allowed
        return ""
    end

    function os.date(format, time, ...)
        if (isstring(format) or isnumber(format)) then
            format = string.gsub(format, "%%[^aAbBcdHIjmMpSUwWxXyYz]", replace)
        elseif (format ~= nil) then
            argError(Val, 1, "string")
        end

        if (not (time == nil or isnumber(time)) and (not isstring(time) or tonumber(time) == nil)) then
            argError(Val, 2, "number")
        end

        return osdate(format, time, ...)
    end
end

timer.Simple(3, function()
    if DarkRP.disabledDefaults["workarounds"]["SkidCheck"] then return end

    -- Malicious addons that kicks players this one person doesn't like.
    if not istable(Skid) then return end
    Skid.Check = fnothing
    hook.Remove("CheckPassword", "Skid.CheckPassword")

    MsgC(Color(0, 255, 0), "SkidCheck", Color(255, 255, 255), " has been ", Color(255, 0, 0), "DISABLED\n", Color(255, 255, 255), [[
    SkidCheck is old, bad and has been disabled.
    To see why check here: https://github.com/FPtje/DarkRP/blob/764f82a714b6504633a0b36577d7908ec236c9b6/gamemode/modules/workarounds/sh_workarounds.lua#L51
]])
end)

if game.SinglePlayer() or GetConVar("sv_lan"):GetBool() and
   not DarkRP.disabledDefaults["workarounds"]["nil SteamID64 and AccountID local server fix"] then
    local plyMeta = FindMetaTable("Player")

    if SERVER then
        local sid64 = plyMeta.SteamID64

        function plyMeta:SteamID64(...)
            return sid64(self, ...) or "0"
        end
    end

    local aid = plyMeta.AccountID

    function plyMeta:AccountID(...)
        return aid(self, ...) or 0
    end
end


if CLIENT and not DarkRP.disabledDefaults["workarounds"]["Cam function descriptive errors"] then
    local cams3D, cams2D = 0, 0
    local cam_Start = cam.Start

    function cam.Start(tbl, ...)
        -- https://github.com/Facepunch/garrysmod-issues/issues/3361
        if (not istable(tbl)) then
           argError(tbl, 1, "table")
        end

        if (tbl.type == "3D") then
            cams3D = cams3D + 1
        elseif (tbl.type == "2D") then
            cams2D = cams2D + 1
        else
            error("bad argument #1 to '%s' (bad key 'type' - 2D or 3D expected, got %s)", debug.getinfo(1, "n").name, tbl.type, 2)
        end

        -- Could pcall this but it'd be impossible to
        -- tell if a render instance was created or not.
        -- Assume creation/deletion
        return cam_Start(tbl, ...)
    end

    local cam_End3D = cam.End3D
    function cam.End3D(...)
        if (cams3D == 0) then
            error("tried to end invalid render instance", 2)
        end
        cams3D = cams3D - 1
        return cam_End3D(...)
    end
    cam.End = cam.End3D

    local cam_End2D = cam.End2D
    function cam.End2D(...)
        if (cams2D == 0) then
            error("tried to end invalid render instance", 2)
        end
        cams2D = cams2D - 1
        return cam_End2D(...)
    end

    local cams3D2D = 0
    local cam_Start3D2D = cam.Start3D2D

    function cam.Start3D2D(...)
        cams3D2D = cams3D2D + 1
        return cam_Start3D2D(...)
    end

    local cam_End3D2D = cam.End3D2D
    function cam.End3D2D(...)
        if (cams3D2D == 0) then
            error("tried to end invalid render instance", 2)
        end
        cams3D2D = cams3D2D - 1
        return cam_End3D2D(...)
    end
end

if SERVER and not DarkRP.disabledDefaults["workarounds"]["Error on edict limit"] then
    -- https://github.com/FPtje/DarkRP/issues/2640
    local entsCreate = ents.Create
    local entsCreateError = [[
    Unable to create entity.

    The server has come to a point where it has become impossible to create new
    entities. The entity limit has been hit. Try cleaning up the server or
    changing level. In the meantime, expect lots of errors coming from a lot of
    addons.

    If you do decide to send a bug report to ANY addon, please include this
    message.]]

    local function varArgsLen(...)
        return {...}, select("#", ...)
    end

    function ents.Create(name, ...)
        local res, len = varArgsLen(entsCreate(name, ...))

        if res[1] == NULL and ents.GetEdictCount() >= 8176 then
            DarkRP.error(entsCreateError, 2, { string.format("Affected entity: '%s'", name) })
        end

        return unpack(res, 1, len)
    end
end

--[[---------------------------------------------------------------------------
Generic InitPostEntity workarounds
---------------------------------------------------------------------------]]
hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
    if CLIENT then
        if not DarkRP.disabledDefaults["workarounds"]["White flashbang flashes"] then
            -- Removes the white flashes when the server lags and the server has flashbang. Workaround because it's been there for fucking years
            hook.Remove("HUDPaint","drawHudVital")
        end

        -- Fuck up APAnti
        if not DarkRP.disabledDefaults["workarounds"]["APAnti"] then
            net.Receivers.sblockgmspawn = nil
            hook.Remove("PlayerBindPress", "_sBlockGMSpawn")
        end
        return
    end
    local commands = concommand.GetTable()
    if not DarkRP.disabledDefaults["workarounds"]["Durgz witty sayings"] and commands["durgz_witty_sayings"] then
        game.ConsoleCommand("durgz_witty_sayings 0\n") -- Deals with the cigarettes exploit. I'm fucking tired of them. I hate having to fix other people's mods, but this mod maker is retarded and refuses to update his mod.
    end

    -- Remove ULX /me command. (the /me command is the only thing this hook does)
    if not DarkRP.disabledDefaults["workarounds"]["ULX /me command"] then
        hook.Remove("PlayerSay", "ULXMeCheck")
    end

    -- why can people even save multiplayer games?
    -- Lag exploit
    if not DarkRP.disabledDefaults["workarounds"]["gm_save"] then
        concommand.Remove("gm_save")
    end

    -- Remove that weird rooftop spawn in rp_downtown_v4c_v2
    if not DarkRP.disabledDefaults["workarounds"]["rp_downtown_v4c_v2 rooftop spawn"] and
    game.GetMap() == "rp_downtown_v4c_v2" then
        for _, v in ipairs(ents.FindByClass("info_player_terrorist")) do
            v:Remove()
        end
    end
end)

--[[---------------------------------------------------------------------------
Fuck up APAnti. These hooks send unnecessary net messages.
---------------------------------------------------------------------------]]
if not DarkRP.disabledDefaults["workarounds"]["APAnti"] then
    timer.Simple(3, function()
        hook.Remove("Move", "_APA.Settings.AllowGMSpawn")
        hook.Remove("PlayerSpawnObject", "_APA.Settings.AllowGMSpawn")
    end)
end

--[[---------------------------------------------------------------------------
Wire field generator exploit
---------------------------------------------------------------------------]]
if SERVER and not DarkRP.disabledDefaults["workarounds"]["Wire field generator exploit fix"] then
    hook.Add("OnEntityCreated", "DRP_WireFieldGenerator", function(ent)
        timer.Simple(0, function()
            if IsValid(ent) and ent:GetClass() == "gmod_wire_field_device" then
                local TriggerInput = ent.TriggerInput
                function ent:TriggerInput(iname, value)
                    if iname == "Distance" and isnumber(value) then
                        value = math.min(value, 400)
                    end
                    TriggerInput(self, iname, value)
                end
            end
        end)
    end)
end

--[[---------------------------------------------------------------------------
Door tool is shitty
Let's fix that huge class exploit
---------------------------------------------------------------------------]]
if not DarkRP.disabledDefaults["workarounds"]["Door tool class fix"] then
    hook.Add("InitPostEntity", "FixDoorTool", function()
        local oldFunc = makedoor
        if isfunction(oldFunc) then
            function makedoor(ply, trace, ang, model, open, close, autoclose, closetime, class, hardware, ...)
                if class ~= "prop_dynamic" and class ~= "prop_door_rotating" then return end

                oldFunc(ply, trace, ang, model, open, close, autoclose, closetime, class, hardware, ...)
            end
        end
    end)

    local allowedDoors = {
        ["prop_dynamic"] = true,
        ["prop_door_rotating"] = true,
        [""] = true
    }

    hook.Add("CanTool", "DoorExploit", function(ply, trace, tool)
        if not IsValid(ply) or not ply:IsPlayer() or not IsValid(ply:GetActiveWeapon()) or not ply:GetActiveWeapon().GetToolObject or not ply:GetActiveWeapon():GetToolObject() then return end

        tool = ply:GetActiveWeapon():GetToolObject()
        if not allowedDoors[string.lower(tool:GetClientInfo("door_class") or "")] then
            return false
        end
    end)
end
--[[---------------------------------------------------------------------------
Anti crash exploit
---------------------------------------------------------------------------]]
if SERVER and not DarkRP.disabledDefaults["workarounds"]["Constraint crash exploit fix"] then
    hook.Add("PropBreak", "drp_AntiExploit", function(attacker, ent)
        if IsValid(ent) and ent:GetPhysicsObject():IsValid() then
            constraint.RemoveAll(ent)
        end
    end)
end

--[[---------------------------------------------------------------------------
Actively deprecate commands
---------------------------------------------------------------------------]]
if SERVER and not DarkRP.disabledDefaults["workarounds"]["Deprecated console commands"] then
    local deprecated = {
        {command = "rp_setname",            alternative = "forcerpname"             },
        {command = "rp_unlock",             alternative = "forceunlock"             },
        {command = "rp_lock",               alternative = "forcelock"               },
        {command = "rp_removeowner",        alternative = "forceremoveowner"        },
        {command = "rp_addowner",           alternative = "forceown"                },
        {command = "rp_unownall",           alternative = "forceunownall"           },
        {command = "rp_unown",              alternative = "forceunown"              },
        {command = "rp_own",                alternative = "forceown"                },
        {command = "rp_tellall",            alternative = "admintellall"            },
        {command = "rp_tell",               alternative = "admintell"               },
        {command = "rp_teamunban",          alternative = "teamunban"               },
        {command = "rp_teamban",            alternative = "teamban"                 },
        {command = "rp_setsalary",          alternative = "setmoney"                },
        {command = "rp_setmoney",           alternative = "setmoney"                },
    }

    local lastDeprecated = 0
    local function msgDeprecated(cmd, ply)
        if CurTime() - lastDeprecated < 0.5 then return end
        lastDeprecated = CurTime()

        DarkRP.notify(ply, 1, 4, ("This command has been deprecated. Please use 'DarkRP %s' or '/%s' instead."):format(cmd.alternative, cmd.alternative))
    end

    for _, cmd in pairs(deprecated) do
        concommand.Add(cmd.command, fp{msgDeprecated, cmd})
    end
end


--[[-------------------------------------------------------------------------
CAC tends to kick innocent people when they use the x86_64 branch. Since the
author is unable to maintain it, it is better to disable the addon altogether.
---------------------------------------------------------------------------]]
local disableCacMsg = [[CAC was detected on this server and has been disabled.]]
if SERVER and not DarkRP.disabledDefaults["workarounds"]["disable CAC"] then
    timer.Create("disable CAC", 2, 1, function()
        if not CAC then return end

        --remove CAC's hooks
        hook.Remove("CheckPassword"      , "CAC.CheckPassword")
        hook.Remove("Initialize"         , "CAC.LuaWhitelistController.261b4998")
        hook.Remove("OnNPCKilled"        , "CAC.Aimbotdetector")
        hook.Remove("PlayerDeath"        , "CAC.AimbotDetector")
        hook.Remove("PlayerInitialSpawn" , "CAC.PlayerMonitor.PlayerConnected")
        hook.Remove("PlayerSay"          , "CAC.ChatCommands")
        hook.Remove("SetupMove"          , "CAC.MoveHandler")
        hook.Remove("ShutDown"           , "CAC")
        hook.Remove("Think"              , "CAC.DelayedCalls")
        hook.Remove("Tick"               , "CAC.PlayerMonitor.ProcessQueue")
        hook.Remove("player_disconnect"  , "CAC.PlayerMonitor.PlayerDisconnected")

        --remove CAC's timers
        timer.Remove("CAC.AdminUIBootstrapper")
        timer.Remove("CAC.DataUpdater")
        timer.Remove("CAC.IncidentController")
        timer.Remove("CAC.LivePlayerSessionController")
        timer.Remove("CAC.SettingsSaver")

        --remove CAC's net receivers
        net.Receivers[CAC.Identifiers.MultiplexedDataChannelName] = nil
        net.Receivers[CAC.Identifiers.AdminChannelName] = nil

        for k,v in pairs(CAC) do
            if istable(CAC[k]) and CAC[k].dtor then CAC[k]:dtor() end
        end

        CAC = nil

        MsgC(Color(0, 255, 0), "Cake Anticheat (CAC)", Color(255, 255, 255), " has been ", Color(255, 0, 0), "DISABLED\n", Color(253, 151, 31), disableCacMsg)
    end)
end

-- Custom Workarounds from SCP-Optimized
-- Made by OverlordAkise

-- Dont allow to drop SCP weapons
hook.Add("canDropWeapon","so_dontdropscpweps",function(ply, weapon)
    if not IsValid(weapon) then return false end
    local class = string.lower(weapon:GetClass())
    if string.StartWith(class,"weapon_scp") then return false end
end)

-- Disable Thirdperson wallhack exploit
hook.Add("PlayerInitialSpawn", "so_fix_thirdperson_whak", function(ply)
  RunConsoleCommand("simple_thirdperson_forcecollide",1)
  hook.Remove("PlayerInitialSpawn", "so_fix_thirdperson_whak")
end)

-- Allow sitting players to be shot
hook.Add("PlayerInitialSpawn", "so_fix_sit_nodamage", function(ply)
  RunConsoleCommand("sitting_can_damage_players_sitting",1)
  hook.Remove("PlayerInitialSpawn", "so_fix_sit_nodamage")
end)

-- Slow down people who bhop
hook.Add( "OnPlayerHitGround", "so_slow_jump", function(ply, inWater, onFloater, speed)
	local vel = ply:GetVelocity()
	if vel.x > 600 or vel.x < -600 or vel.y > 600 or vel.y < -600 then
		ply:SetVelocity( Vector( -( vel.x / 2 ), -( vel.y / 2 ), 0 ) )
	end
end)
