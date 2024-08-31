-- How to use:
-- If a player uses /afk, they go into AFK mode, they will not be autodemoted and their salary is set to $0 (you can still be killed though!).

local function SetAFK(ply)
    local rpname = ply:getDarkRPVar("rpname")
    ply:setSelfDarkRPVar("AFK", not ply:getDarkRPVar("AFK"))

    ply.blackScreen = ply:getDarkRPVar("AFK")
    SendUserMessage("blackScreen", ply, ply:getDarkRPVar("AFK"))

    if ply:getDarkRPVar("AFK") then
        DarkRP.retrieveSalary(ply, function(amount) ply.OldSalary = amount end)
        ply.OldJob = ply:getDarkRPVar("job")
        ply.lastHealth = ply:Health()
        DarkRP.notifyAll(0, 5, DarkRP.getPhrase("player_now_afk", rpname))

        ply.AFK_Timer = math.huge

        ply:KillSilent()
        ply:Lock()
    else
        ply.AFK_Timer = CurTime() + GAMEMODE.Config.afkdemotetime
        DarkRP.notifyAll(1, 5, DarkRP.getPhrase("player_no_longer_afk", rpname))
        ply:Spawn()
        ply:UnLock()

        ply:SetHealth(ply.lastHealth and ply.lastHealth > 0 and ply.lastHealth or 100)
        ply.lastHealth = nil
    end

    hook.Run("playerSetAFK", ply, ply:getDarkRPVar("AFK"))
end

DarkRP.defineChatCommand("afk", function(ply)
    if ply.DarkRPLastAFK and not ply:getDarkRPVar("AFK") and ply.DarkRPLastAFK > CurTime() - GAMEMODE.Config.AFKDelay then
        DarkRP.notify(ply, 0, 5, DarkRP.getPhrase("unable_afk_spam_prevention"))
        return ""
    end

    if hook.Run("canGoAFK", ply, not ply:getDarkRPVar("AFK")) == false then return "" end

    if not ply:getDarkRPVar("AFK") then
        DarkRP.notify(ply,1,5,"[AFK] Please stand still for 5s to be moved AFK!")
        ply.cAFKPos = ply:GetPos()
        timer.Simple(5,function()
            if not IsValid(ply) then return end
            if ply.cAFKPos == ply:GetPos() then
                ply.DarkRPLastAFK = CurTime()
                SetAFK(ply)
            else
                DarkRP.notify(ply,1,5,"[AFK] Error: You moved!")
            end
        end)
    else
        ply.DarkRPLastAFK = CurTime()
        SetAFK(ply)
    end

    return ""
end)

hook.Add("PlayerInitialSpawn", "StartAFKOnPlayer", function(ply)
    ply.AFK_Timer = CurTime() + GAMEMODE.Config.afkdemotetime
end)

hook.Add("KeyPress", "DarkRPKeyReleasedCheck", function(ply, key)
    ply.AFK_Timer = CurTime() + GAMEMODE.Config.afkdemotetime
end)

timer.Create("DarkRPKeyPressedCheck", 1, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if ply.AFK_Timer and CurTime() > ply.AFK_Timer and not ply:getDarkRPVar("AFK") and not ply:IsBot() then
            SetAFK(ply)
            ply.AFK_Timer = math.huge
        end
    end
end)

hook.Add("playerCanChangeTeam", "AFKCanChangeTeam", function(ply, t, force)
    if ply:getDarkRPVar("AFK") and (not force or t ~= GAMEMODE.DefaultTeam) then
        local TEAM = RPExtraTeams[t]
        if TEAM then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", GAMEMODE.Config.chatCommandPrefix .. TEAM.command, "AFK")) end
        return false
    end
end)

-- Freeze AFK player's salary
hook.Add("playerGetSalary", "AFKGetSalary", function(ply, amount)
    if ply:getDarkRPVar("AFK") then
        return true, "", 0
    end
end)

-- For when a player's team is changed by force
hook.Add("OnPlayerChangedTeam", "AFKCanChangeTeam", function(ply)
    if not ply:getDarkRPVar("AFK") then return end
    ply.OldSalary = ply:getDarkRPVar("salary")
    ply.OldJob = nil
    ply:setSelfDarkRPVar("salary", 0)
end)
