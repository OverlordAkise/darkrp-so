--[[---------------------------------------------------------------------------
The fonts that DarkRP uses
---------------------------------------------------------------------------]]
local function loadFonts()
    surface.CreateFont("DarkRPHUD1", {
        size = 20,
        weight = 600,
        antialias = true,
        shadow = true,
        font = "Roboto"})

    surface.CreateFont("DarkRPHUD2", {
        size = 23,
        weight = 400,
        antialias = true,
        shadow = false,
        font = "Roboto"})

    surface.CreateFont("Roboto20", {
        size = 20,
        weight = 600,
        antialias = true,
        shadow = false,
        font = "Roboto"})

    surface.CreateFont("TabLarge", {
        size = 18,
        weight = 700,
        antialias = true,
        shadow = false,
        font = "Roboto"})

    surface.CreateFont("UiBold", {
        size = 16,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Verdana"})

end
loadFonts()
