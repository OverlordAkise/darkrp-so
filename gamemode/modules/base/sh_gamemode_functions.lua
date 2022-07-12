function GM:SetupMove(ply, mv, cmd)
    return self.Sandbox.SetupMove(self, ply, mv, cmd)
end

function GM:StartCommand(ply, usrcmd)
end

function GM:OnPlayerChangedTeam(ply, oldTeam, newTeam)
    if RPExtraTeams[oldTeam] and RPExtraTeams[oldTeam].OnPlayerLeftTeam then
        RPExtraTeams[oldTeam].OnPlayerLeftTeam(ply, newTeam)
    end

    if RPExtraTeams[newTeam] and RPExtraTeams[newTeam].OnPlayerChangedTeam then
        RPExtraTeams[newTeam].OnPlayerChangedTeam(ply, oldTeam, newTeam)
    end
end

hook.Add("loadCustomDarkRPItems", "CAMI privs", function()

    CAMI.RegisterPrivilege{
        Name = "DarkRP_GetAdminWeapons",
        MinAccess = "admin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_SetDoorOwner",
        MinAccess = "admin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_ChangeDoorSettings",
        MinAccess = "superadmin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_AdminCommands",
        MinAccess = "admin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_SetMoney",
        MinAccess = "superadmin"
    }

    for _, v in pairs(RPExtraTeams) do
        if not v.vote or v.admin and v.admin > 1 then continue end

        local toAdmin = {[0] = "admin", [1] = "superadmin"}
        CAMI.RegisterPrivilege{
            Name = "DarkRP_GetJob_" .. v.command,
            MinAccess = toAdmin[v.admin or 0]-- Add privileges for the teams that are voted for
        }
    end
end)
