-- Modification loader.

--[[---------------------------------------------------------------------------
Disabled defaults
---------------------------------------------------------------------------]]
DarkRP.disabledDefaults = {}
DarkRP.disabledDefaults["modules"] = {
    ["afk"]              = false,
    ["chatsounds"]       = false,
    ["events"]           = false,
    ["hud"]              = false,
    ["hungermod"]        = true,
    ["playerscale"]      = false,
    ["sleep"]            = false,
}

DarkRP.disabledDefaults["ammo"]             = {}
DarkRP.disabledDefaults["doorgroups"]       = {}
DarkRP.disabledDefaults["entities"]         = {}
DarkRP.disabledDefaults["food"]             = {}
DarkRP.disabledDefaults["groupchat"]        = {}
DarkRP.disabledDefaults["hitmen"]           = {}
DarkRP.disabledDefaults["jobs"]             = {}
DarkRP.disabledDefaults["shipments"]        = {}
DarkRP.disabledDefaults["vehicles"]         = {}
DarkRP.disabledDefaults["workarounds"]      = {}

-- The client cannot use simplerr.runLuaFile because of restrictions in GMod.
-- simplerr was here
local doInclude = include

if file.Exists("darkrp_config/disabled_defaults.lua", "LUA") then
    if SERVER then AddCSLuaFile("darkrp_config/disabled_defaults.lua") end
    doInclude("darkrp_config/disabled_defaults.lua")
end

--[[---------------------------------------------------------------------------
Config
---------------------------------------------------------------------------]]
local configFiles = {
    "darkrp_config/settings.lua",
    "darkrp_config/licenseweapons.lua",
}

for _, File in pairs(configFiles) do
    if not file.Exists(File, "LUA") then continue end

    if SERVER then AddCSLuaFile(File) end
    doInclude(File)
end
if SERVER and file.Exists("darkrp_config/mysql.lua", "LUA") then doInclude("darkrp_config/mysql.lua") end

--[[---------------------------------------------------------------------------
Modules
---------------------------------------------------------------------------]]
local function loadModules()
    local fol = "darkrp_modules/"

    local _, folders = file.Find(fol .. "*", "LUA")

    for _, folder in SortedPairs(folders, true) do
        if folder == "." or folder == ".." or GAMEMODE.Config.DisabledCustomModules[folder] then continue end

        for _, File in SortedPairs(file.Find(fol .. folder .. "/sh_*.lua", "LUA"), true) do
            if SERVER then
                AddCSLuaFile(fol .. folder .. "/" .. File)
            end

            if File == "sh_interface.lua" then continue end
            doInclude(fol .. folder .. "/" .. File)
        end

        if SERVER then
            for _, File in SortedPairs(file.Find(fol .. folder .. "/sv_*.lua", "LUA"), true) do
                if File == "sv_interface.lua" then continue end
                doInclude(fol .. folder .. "/" .. File)
            end
        end

        for _, File in SortedPairs(file.Find(fol .. folder .. "/cl_*.lua", "LUA"), true) do
            if File == "cl_interface.lua" then continue end

            if SERVER then
                AddCSLuaFile(fol .. folder .. "/" .. File)
            else
                doInclude(fol .. folder .. "/" .. File)
            end
        end
    end
end

local function loadLanguages()
    local fol = "darkrp_language/"

    local files, _ = file.Find(fol .. "*", "LUA")
    for _, File in pairs(files) do
        if SERVER then AddCSLuaFile(fol .. File) end
        doInclude(fol .. File)
    end
end

local customFiles = {
    "darkrp_customthings/jobs.lua",
    "darkrp_customthings/shipments.lua",
    "darkrp_customthings/entities.lua",
    "darkrp_customthings/vehicles.lua",
    "darkrp_customthings/food.lua",
    "darkrp_customthings/ammo.lua",
    "darkrp_customthings/groupchats.lua",
    "darkrp_customthings/categories.lua",
    "darkrp_customthings/doorgroups.lua",
}
local function loadCustomDarkRPItems()
    for _, File in pairs(customFiles) do
        if not file.Exists(File, "LUA") then continue end
        if File == "darkrp_customthings/food.lua" and DarkRP.disabledDefaults["modules"]["hungermod"] then continue end

        if SERVER then AddCSLuaFile(File) end
        doInclude(File)
    end
end


function GM:DarkRPFinishedLoading()
    -- GAMEMODE gets set after the last statement in the gamemode files is run. That is not the case in this hook
    GAMEMODE = GAMEMODE or GM

    loadLanguages()
    loadModules()
    loadCustomDarkRPItems()
    hook.Call("loadCustomDarkRPItems", self)
    hook.Call("postLoadCustomDarkRPItems", self)
end
