AddCSLuaFile("pp/sh_cppi.lua")
AddCSLuaFile("pp/sh_settings.lua")
AddCSLuaFile("pp/client/main.lua")

include("pp/sh_settings.lua")
include("pp/sh_cppi.lua")
include("pp/server/settings.lua")
include("pp/server/core.lua")
include("pp/server/antispam.lua")
include("pp/server/defaultblockedmodels.lua")

--[[---------------------------------------------------------------------------
DarkRP blocked entities
---------------------------------------------------------------------------]]
local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}

FPP.AddDefaultBlocked(blockTypes, "food")
FPP.AddDefaultBlocked(blockTypes, "microwave")
FPP.AddDefaultBlocked(blockTypes, "spawned_ammo")
FPP.AddDefaultBlocked(blockTypes, "spawned_food")
FPP.AddDefaultBlocked(blockTypes, "spawned_money")
FPP.AddDefaultBlocked(blockTypes, "spawned_shipment")
FPP.AddDefaultBlocked(blockTypes, "spawned_weapon")
