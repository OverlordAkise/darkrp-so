local ss = SysTime()

include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("libraries/sh_cami.lua")
AddCSLuaFile("libraries/modificationloader.lua")
AddCSLuaFile("libraries/fn.lua")

AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/addentities.lua")
AddCSLuaFile("config/jobrelated.lua")
AddCSLuaFile("config/ammotypes.lua")

AddCSLuaFile("cl_init.lua")


function DarkRP.log(text)
    print("[darkrplog] "..text)
end

include("config/_MySQL.lua")
include("config/config.lua")
include("config/licenseweapons.lua")
include("config/sh_customconfig.lua")

include("libraries/fn.lua")
include("libraries/sh_cami.lua")
include("libraries/modificationloader.lua")
include("libraries/mysqlite.lua")

resource.AddFile("materials/vgui/entities/keys.vmt")
resource.AddFile("materials/vgui/entities/lockpick.vmt")
resource.AddFile("materials/vgui/entities/med_kit.vmt")
resource.AddFile("materials/vgui/entities/pocket.vmt")
resource.AddFile("materials/vgui/entities/stunstick.vmt")
resource.AddFile("materials/vgui/entities/weaponchecker.vmt")


hook.Call("DarkRPPreLoadModules", GM)


--Modules for client
AddCSLuaFile("config/sh_customconfig.lua")
AddCSLuaFile("modules/workarounds/sh_workarounds.lua")
AddCSLuaFile("modules/sh_playerscale.lua")
AddCSLuaFile("modules/money/sh_money.lua")
AddCSLuaFile("modules/language/sh_language.lua")
AddCSLuaFile("modules/language/sh_english.lua")
AddCSLuaFile("modules/hud/cl_hud.lua")
AddCSLuaFile("modules/fspectate/sh_init.lua")
AddCSLuaFile("modules/fspectate/cl_init.lua")
AddCSLuaFile("modules/fpp/cl_fpp.lua")
AddCSLuaFile("modules/fpp/sh_fpp.lua")
AddCSLuaFile("modules/doorsystem/sh_doors.lua")
AddCSLuaFile("modules/doorsystem/cl_doors.lua")
AddCSLuaFile("modules/cppi/sh_cppi.lua")
AddCSLuaFile("modules/chat/sh_chatcommands.lua")
AddCSLuaFile("modules/chat/cl_chat.lua")
AddCSLuaFile("modules/base/sh_util.lua")
AddCSLuaFile("modules/base/sh_simplerr.lua")
AddCSLuaFile("modules/base/sh_playerclass.lua")
AddCSLuaFile("modules/base/sh_gamemode_functions.lua")
AddCSLuaFile("modules/base/sh_entityvars.lua")
AddCSLuaFile("modules/base/sh_createitems.lua")
AddCSLuaFile("modules/base/sh_checkitems.lua")
AddCSLuaFile("modules/base/cl_util.lua")
AddCSLuaFile("modules/base/cl_jobmodels.lua")
AddCSLuaFile("modules/base/cl_gamemode_functions.lua")
AddCSLuaFile("modules/base/cl_fonts.lua")
AddCSLuaFile("modules/base/cl_entityvars.lua")
AddCSLuaFile("modules/base/cl_drawfunctions.lua")
AddCSLuaFile("modules/animations/sh_animations.lua")
--afk
AddCSLuaFile("modules/afk/sh_commands.lua")
AddCSLuaFile("modules/afk/cl_afk.lua")


--Compatibility
AddCSLuaFile("modules/allow_compatibility.lua")


--server modules to load
--chat stuff
include("modules/chat/sh_chatcommands.lua")
include("modules/chat/sv_chat.lua")--reversed sv_chat and sv_chatcommand or error
include("modules/chat/sv_chatcommands.lua")

include("modules/chatsounds.lua")
include("modules/cssmount.lua")
include("modules/passengermodcompat.lua")
include("modules/workarounds/sh_workarounds.lua")
include("modules/workarounds/sv_antimultirun.lua")
include("modules/sleep/sv_sleep.lua")
include("modules/positions/sv_spawnpos.lua")
include("modules/positions/sv_database.lua")
--police to bot
include("modules/sh_playerscale.lua")
include("modules/money/sh_money.lua")
include("modules/money/sv_money.lua")
include("modules/language/sh_language.lua")
include("modules/language/sh_english.lua")
include("modules/jobs/sv_jobs.lua")
include("modules/hud/sv_admintell.lua")
include("modules/fspectate/sh_init.lua")
include("modules/fspectate/sv_init.lua")
include("modules/fpp/sh_fpp.lua")
include("modules/fpp/sv_fpp.lua")
include("modules/doorsystem/sh_doors.lua")
include("modules/doorsystem/sv_doorvars.lua")
include("modules/doorsystem/sv_doors.lua")
include("modules/doorsystem/sv_dooradministration.lua")
include("modules/cppi/sh_cppi.lua")
--chat to top (errors because other modules need chatAddreceiver)
include("modules/base/sh_util.lua")
include("modules/base/sh_simplerr.lua")
include("modules/base/sh_playerclass.lua")
include("modules/base/sh_gamemode_functions.lua")
include("modules/base/sh_entityvars.lua")
include("modules/base/sh_createitems.lua")
include("modules/base/sh_checkitems.lua")
include("modules/base/sv_util.lua")
include("modules/base/sv_purchasing.lua")
include("modules/base/sv_jobmodels.lua")
include("modules/base/sv_gamemode_functions.lua")
include("modules/base/sv_entityvars.lua")
include("modules/base/sv_data.lua")
include("modules/animations/sh_animations.lua")
--afk
include("modules/afk/sv_afk.lua")
include("modules/afk/sh_commands.lua")

--Compatibility
include("modules/allow_compatibility.lua")

DarkRP.DARKRP_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")
DarkRP.DARKRP_LOADING = nil

--DarkRP.finish() 

hook.Call("DarkRPFinishedLoading", GM)
MySQLite.initialize()

print("Loaded SV in "..(SysTime()-ss).."s")
