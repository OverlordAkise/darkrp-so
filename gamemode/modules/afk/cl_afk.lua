local TextColor = Color(255, 0, 0, 255)

local function AFKHUDPaint()
    local scrw = ScrW()/2
    local scrh = ScrH()/2
    draw.DrawNonParsedSimpleText("AFK", "DarkRPHUD2", scrw, scrh - 100, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.DrawNonParsedSimpleText(DarkRP.getPhrase("afk_cmd_to_exit"), "DarkRPHUD2", scrw, scrh + 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("DarkRPVarChanged","luctus_so_optimized_afk",function(ply, varname, oldValue, newvalue)
    if varname == "AFK" then
        if newvalue then
            hook.Add("HUDPaint", "AFK_HUD", AFKHUDPaint)
        else
            hook.Remove("HUDPaint", "AFK_HUD")
        end
    end
end)
