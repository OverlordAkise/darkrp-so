
--[[
Changes:
    Always respawn when changing jobs (KillSilent)
    Removed job.PlayerChangeTeam
    Removed Config.removeclassitems (entities from you wont be removed on job change)
    Removed "NeedToChangeFrom"
    Job payday timer is now fixed interval after joining
--]]

local function canChangeTeam(self,prevTeam,targetTeam,force)
    if force return true end
    if targetTeam == GAMEMODE.DefaultTeam then return true end
    if targetTeam == prevTeam then return false end
    
    if GAMEMODE.Config.changejobtime - (CurTime() - self.LastJob) >= 0 then
        notify(self, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(GAMEMODE.Config.changejobtime - (CurTime() - self.LastJob)), "/job"))
        return false
    end
    
    local max = TEAM.max
    local numPlayers = team.NumPlayers(t)
    if not ignoreMaxMembers and
    max ~= 0 and -- No limit
    (max >= 1 and numPlayers >= max or -- absolute maximum
    max < 1 and (numPlayers + 1) / player.GetCount() > max) then -- fractional limit (in percentages)
        notify(self, 1, 4, DarkRP.getPhrase("team_limit_reached", TEAM.name))
        return false
    end
    
    if not TEAM.customCheck(self) then
        local message = isfunction(TEAM.CustomCheckFailMsg) and TEAM.CustomCheckFailMsg(self, TEAM) or
            TEAM.CustomCheckFailMsg or
            DarkRP.getPhrase("unable", team.GetName(t), "")
        notify(self, 1, 4, message)
        return false
    end
    
    local allowed, time = self:changeAllowed(t)
    if not allowed then
        local notif = time and DarkRP.getPhrase("have_to_wait", math.ceil(time), "/job, " .. DarkRP.getPhrase("banned_or_demoted")) or DarkRP.getPhrase("unable", team.GetName(t), DarkRP.getPhrase("banned_or_demoted"))
        notify(self, 1, 4, notif)
        return false
    end
    
    local hookValue, reason = hook.Call("playerCanChangeTeam", nil, self, t, force)
    if hookValue == false then
        if reason then
            notify(self, 1, 4, reason)
        end
        return false
    end
    
    return true
end


local meta = FindMetaTable("Player")
function meta:changeTeam(t, force, suppressNotification, ignoreMaxMembers)
    local prevTeam = self:Team()
    local notify = suppressNotification and fnothing or DarkRP.notify
    local notifyAll = suppressNotification and fnothing or DarkRP.notifyAll
    local TEAM = RPExtraTeams[t]
    if not TEAM then return false end
    
    if not canChangeTeam(self,prevTeam,t,force) then return false end
    
    self:updateJob(TEAM.name)
    self:setSelfDarkRPVar("salary", TEAM.salary)
    notifyAll(0, 4, DarkRP.getPhrase("job_has_become", self:Nick(), TEAM.name))

    self:SetTeam(t)
    hook.Call("OnPlayerChangedTeam", GAMEMODE, self, prevTeam, t)
    DarkRP.log(self:Nick() .. " (" .. self:SteamID() .. ") changed to " .. team.GetName(t), nil, Color(100, 0, 255))
    if self:InVehicle() then self:ExitVehicle() end
    self:KillSilent()
    
    umsg.Start("OnChangedTeam", self)
        umsg.Short(prevTeam)
        umsg.Short(t)
    umsg.End()
    return true
end

function meta:updateJob(job)
    self:setDarkRPVar("job", job)
    self.LastJob = CurTime()
end

function meta:teamUnBan(Team)
    self.bannedfrom = self.bannedfrom or {}
    self.bannedfrom[Team] = nil
end

function meta:teamBan(t, time)
    if not self.bannedfrom then self.bannedfrom = {} end
    t = t or self:Team()
    self.bannedfrom[t] = true
    local timerid = "teamban" .. self:UserID() .. "," .. t
    timer.Remove(timerid)
    if time == 0 then return end
    timer.Create(timerid, time or 300, 1, function()
        if not IsValid(self) then return end
        self:teamUnBan(t)
    end)
end

function meta:teamBanTimeLeft(t)
    local team = t or self:Team()
    if not team then
      team = ""
    end
    return timer.TimeLeft("teamban" .. self:UserID() .. "," .. team)
end

function meta:changeAllowed(t)
    if self.bannedfrom and self.bannedfrom[t] then return false, self:teamBanTimeLeft(t) end
    return true
end

function GM:canChangeJob(ply, args)
    if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then return false, DarkRP.getPhrase("have_to_wait", math.ceil(10 - (CurTime() - ply.LastJob)), "/job") end
    if not ply:Alive() then return false end

    local len = string.len(args)

    if len < 3 then return false, DarkRP.getPhrase("unable", "/job", ">2") end
    if len > 25 then return false, DarkRP.getPhrase("unable", "/job", "<26") end

    return true
end

--Commands
DarkRP.defineChatCommand("job", function(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    if not GAMEMODE.Config.customjobs then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/job", ""))
        return ""
    end

    local canChangeJob, message, replace = gamemode.Call("canChangeJob", ply, args)
    if canChangeJob == false then
        DarkRP.notify(ply, 1, 4, message or DarkRP.getPhrase("unable", "/job", ""))
        return ""
    end

    local job = replace or args
    DarkRP.notifyAll(2, 4, DarkRP.getPhrase("job_has_become", ply:Nick(), job))
    ply:updateJob(job)
    return ""
end)

DarkRP.definePrivilegedChatCommand("teamban", "DarkRP_AdminCommands", function(ply, args)
    local ent = args[1]
    local Team = args[2]

    if not Team then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return
    end

    local target = DarkRP.findPlayer(ent)
    if not target or not IsValid(target) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", ent or ""))
        return
    end

    local found = false
    for k, v in pairs(RPExtraTeams) do
        if string.lower(v.name) == string.lower(Team) or string.lower(v.command) == string.lower(Team) or k == tonumber(Team or -1) then
            Team = k
            found = true
            break
        end
    end

    if not found then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", Team or ""))
        return
    end

    local time = tonumber(args[3] or 0)

    target:teamBan(tonumber(Team), time)

    local nick
    if ply:EntIndex() == 0 then
        nick = "Console"
    else
        nick = ply:Nick()
    end
    DarkRP.notifyAll(0, 5, DarkRP.getPhrase("x_teambanned_y_for_z", nick, target:Nick(), team.GetName(tonumber(Team)), time / 60))
end)

DarkRP.definePrivilegedChatCommand("teamunban", "DarkRP_AdminCommands", function(ply, args)
    if #args < 2 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return
    end

    local ent = args[1]
    local Team = args[2]

    local target = DarkRP.findPlayer(ent)
    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", ent or ""))
        return
    end

    local found = false
    for k, v in pairs(RPExtraTeams) do
        if string.lower(v.name) == string.lower(Team) or string.lower(v.command) == string.lower(Team) then
            Team = k
            found = true
            break
        end
        if k == tonumber(Team or -1) then
            found = true
            break
        end
    end

    if not found then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", Team or ""))
        return
    end

    target:teamUnBan(tonumber(Team))

    local nick
    if ply:EntIndex() == 0 then
        nick = "Console"
    else
        nick = ply:Nick()
    end
    DarkRP.notifyAll(0, 5, DarkRP.getPhrase("x_teamunbanned_y", nick, target:Nick(), team.GetName(tonumber(Team))))
end)
