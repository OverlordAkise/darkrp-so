local TextColor = Color(GetConVar("Healthforeground1"):GetFloat(), GetConVar("Healthforeground2"):GetFloat(), GetConVar("Healthforeground3"):GetFloat(), GetConVar("Healthforeground4"):GetFloat())

local function AFKHUDPaint()
    local scrw = ScrW()/2
    local scrh = ScrH()/2
    draw.DrawNonParsedSimpleText(DarkRP.getPhrase("afk_mode"), "DarkRPHUD2", scrw, scrh - 100, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.DrawNonParsedSimpleText(DarkRP.getPhrase("salary_frozen"), "DarkRPHUD2", scrw, scrh - 60, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if not LocalPlayer():getDarkRPVar("AFKDemoted") then
        draw.DrawNonParsedSimpleText(DarkRP.getPhrase("no_auto_demote"), "DarkRPHUD2", scrw, scrh - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        draw.DrawNonParsedSimpleText(DarkRP.getPhrase("youre_afk_demoted"), "DarkRPHUD2", scrw, scrh - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

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
