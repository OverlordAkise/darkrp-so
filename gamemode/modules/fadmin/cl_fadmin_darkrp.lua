if not FAdmin or not FAdmin.StartHooks then return end
FAdmin.StartHooks["DarkRP"] = function()
    -- DarkRP information:
    FAdmin.ScoreBoard.Player:AddInformation("Money", function(ply) if LocalPlayer():IsAdmin() then return DarkRP.formatMoney(ply:getDarkRPVar("money")) end end)
    FAdmin.ScoreBoard.Player:AddInformation("Steam name", function(ply) return ply:SteamName() end)
    FAdmin.ScoreBoard.Player:AddInformation("Community link", function(ply) return FAdmin.SteamToProfile(ply) end)
    FAdmin.ScoreBoard.Player:AddInformation("Rank", function(ply)
        if FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SeeAdmins") then
            return ply:GetUserGroup()
        end
    end)

    --Teamban
    local function teamban(ply, button)
        local menu = DermaMenu()

        local Padding = vgui.Create("DPanel")
        Padding:SetPaintBackgroundEnabled(false)
        Padding:SetSize(1,5)
        menu:AddPanel(Padding)

        local Title = vgui.Create("DLabel")
        Title:SetText("  Jobs:\n")
        Title:SetFont("UiBold")
        Title:SizeToContents()
        Title:SetTextColor(color_black)
        menu:AddPanel(Title)

        local command = "teamban"
        local uid = ply:UserID()
        for k, v in SortedPairsByMemberValue(RPExtraTeams, "name") do
            local submenu = menu:AddSubMenu(v.name)
            submenu:AddOption("2 minutes",     function() RunConsoleCommand("darkrp", command, uid, k, 120)  end)
            submenu:AddOption("Half an hour",  function() RunConsoleCommand("darkrp", command, uid, k, 1800) end)
            submenu:AddOption("An hour",       function() RunConsoleCommand("darkrp", command, uid, k, 3600) end)
            submenu:AddOption("Until restart", function() RunConsoleCommand("darkrp", command, uid, k, 0)    end)
        end
        menu:Open()
    end
    FAdmin.ScoreBoard.Player:AddActionButton("Ban from job", "fadmin/icons/changeteam", Color(200, 0, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "DarkRP_AdminCommands", ply) end, teamban)

    local function teamunban(ply, button)
        local menu = DermaMenu()

        local Padding = vgui.Create("DPanel")
        Padding:SetPaintBackgroundEnabled(false)
        Padding:SetSize(1,5)
        menu:AddPanel(Padding)

        local Title = vgui.Create("DLabel")
        Title:SetText("  Jobs:\n")
        Title:SetFont("UiBold")
        Title:SizeToContents()
        Title:SetTextColor(color_black)
        menu:AddPanel(Title)

        local command = "teamunban"
        local uid = ply:UserID()
        for k, v in SortedPairsByMemberValue(RPExtraTeams, "name") do
            menu:AddOption(v.name, function() RunConsoleCommand("darkrp", command, uid, k) end)
        end
        menu:Open()
    end
    FAdmin.ScoreBoard.Player:AddActionButton("Unban from job", function() return "fadmin/icons/changeteam", "fadmin/icons/disable" end, Color(200, 0, 0, 255),
    function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "DarkRP_AdminCommands", ply) end, teamunban)
end
