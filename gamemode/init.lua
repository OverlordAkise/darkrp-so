local ss = SysTime()
hook.Run("DarkRPStartedLoading")

GM.Version = "2.7.0"
GM.Name = "DarkRP"
GM.Author = "By FPtje Falco et al."

DeriveGamemode("sandbox")
DEFINE_BASECLASS("gamemode_sandbox")

GM.Sandbox = BaseClass

AddCSLuaFile("shared.lua")
AddCSLuaFile("libraries/sh_cami.lua")
AddCSLuaFile("libraries/simplerr.lua")
AddCSLuaFile("libraries/modificationloader.lua")
AddCSLuaFile("libraries/fn.lua")

AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/addentities.lua")
AddCSLuaFile("config/jobrelated.lua")
AddCSLuaFile("config/ammotypes.lua")

AddCSLuaFile("cl_init.lua")

GM.Config = GM.Config or {}
GM.NoLicense = GM.NoLicense or {}

include("shared.lua")

--interfaceloader.lua start
DarkRP = {}
DarkRP.hooks = {}
--interfaceloader.lua end

function DarkRP.log(text)
    print("[darkrpso_log] "..text)
end

include("config/_MySQL.lua")
include("config/config.lua")
include("config/licenseweapons.lua")

include("libraries/fn.lua")
include("libraries/sh_cami.lua")
include("libraries/simplerr.lua")
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
AddCSLuaFile("darkrp/gamemode/modules/workarounds/sh_workarounds.lua")
AddCSLuaFile("darkrp/gamemode/modules/voting/sh_chatcommands.lua")
AddCSLuaFile("darkrp/gamemode/modules/voting/cl_voting.lua")
AddCSLuaFile("darkrp/gamemode/modules/sleep/sh_sleep.lua")
AddCSLuaFile("darkrp/gamemode/modules/positions/sh_commands.lua")
AddCSLuaFile("darkrp/gamemode/modules/police/sh_init.lua")
AddCSLuaFile("darkrp/gamemode/modules/playerscale/cl_playerscale.lua")
AddCSLuaFile("darkrp/gamemode/modules/money/sh_money.lua")
AddCSLuaFile("darkrp/gamemode/modules/money/sh_commands.lua")
AddCSLuaFile("darkrp/gamemode/modules/language/sh_language.lua")
AddCSLuaFile("darkrp/gamemode/modules/language/sh_english.lua")
AddCSLuaFile("darkrp/gamemode/modules/jobs/sh_commands.lua")
AddCSLuaFile("darkrp/gamemode/modules/hud/sh_chatcommands.lua")
AddCSLuaFile("darkrp/gamemode/modules/hud/cl_hud.lua")
AddCSLuaFile("darkrp/gamemode/modules/fspectate/sh_init.lua")
AddCSLuaFile("darkrp/gamemode/modules/fspectate/cl_init.lua")
AddCSLuaFile("darkrp/gamemode/modules/fpp/cl_fpp.lua")
AddCSLuaFile("darkrp/gamemode/modules/doorsystem/sh_doors.lua")
AddCSLuaFile("darkrp/gamemode/modules/doorsystem/cl_doors.lua")
AddCSLuaFile("darkrp/gamemode/modules/deathpov/cl_init.lua")
AddCSLuaFile("darkrp/gamemode/modules/cppi/sh_cppi.lua")
AddCSLuaFile("darkrp/gamemode/modules/chat/sh_chatcommands.lua")
AddCSLuaFile("darkrp/gamemode/modules/chat/cl_chatlisteners.lua")
AddCSLuaFile("darkrp/gamemode/modules/chat/cl_chat.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/sh_util.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/sh_simplerr.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/sh_playerclass.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/sh_gamemode_functions.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/sh_entityvars.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/sh_createitems.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/sh_commands.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/sh_checkitems.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/cl_util.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/cl_jobmodels.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/cl_gamemode_functions.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/cl_fonts.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/cl_entityvars.lua")
AddCSLuaFile("darkrp/gamemode/modules/base/cl_drawfunctions.lua")
AddCSLuaFile("darkrp/gamemode/modules/animations/sh_animations.lua")
--afk
AddCSLuaFile("darkrp/gamemode/modules/afk/sh_commands.lua")
AddCSLuaFile("darkrp/gamemode/modules/afk/cl_afk.lua")


--Compatibility
AddCSLuaFile("darkrp/gamemode/modules/allow_compatibility.lua")


--server modules to load
--chat stuff
include("darkrp/gamemode/modules/chat/sh_chatcommands.lua")
include("darkrp/gamemode/modules/chat/sv_chat.lua")--reversed sv_chat and sv_chatcommand or error
include("darkrp/gamemode/modules/chat/sv_chatcommands.lua")

include("darkrp/gamemode/modules/chatsounds.lua")
include("darkrp/gamemode/modules/cssmount.lua")
include("darkrp/gamemode/modules/passengermodcompat.lua")
include("darkrp/gamemode/modules/workarounds/sh_workarounds.lua")
include("darkrp/gamemode/modules/workarounds/sv_antimultirun.lua")
include("darkrp/gamemode/modules/voting/sh_chatcommands.lua")
include("darkrp/gamemode/modules/voting/sv_votes.lua")
include("darkrp/gamemode/modules/voting/sv_questions.lua")
include("darkrp/gamemode/modules/sleep/sh_sleep.lua")
include("darkrp/gamemode/modules/sleep/sv_sleep.lua")
include("darkrp/gamemode/modules/positions/sh_commands.lua")
include("darkrp/gamemode/modules/positions/sv_spawnpos.lua")
include("darkrp/gamemode/modules/positions/sv_database.lua")
--police to bot
include("darkrp/gamemode/modules/playerscale/sv_playerscale.lua")
include("darkrp/gamemode/modules/money/sh_money.lua")
include("darkrp/gamemode/modules/money/sh_commands.lua")
include("darkrp/gamemode/modules/money/sv_money.lua")
include("darkrp/gamemode/modules/language/sh_language.lua")
include("darkrp/gamemode/modules/language/sh_english.lua")
include("darkrp/gamemode/modules/jobs/sh_commands.lua")
include("darkrp/gamemode/modules/jobs/sv_jobs.lua")
include("darkrp/gamemode/modules/hud/sh_chatcommands.lua")
include("darkrp/gamemode/modules/hud/sv_admintell.lua")
include("darkrp/gamemode/modules/fspectate/sh_init.lua")
include("darkrp/gamemode/modules/fspectate/sv_init.lua")
include("darkrp/gamemode/modules/fpp/sv_fpp.lua")
include("darkrp/gamemode/modules/doorsystem/sh_doors.lua")
include("darkrp/gamemode/modules/doorsystem/sv_doorvars.lua")
include("darkrp/gamemode/modules/doorsystem/sv_doors.lua")
include("darkrp/gamemode/modules/doorsystem/sv_dooradministration.lua")
include("darkrp/gamemode/modules/cppi/sh_cppi.lua")
--chat to top (errors because other modules need chatAddreceiver)
include("darkrp/gamemode/modules/base/sh_util.lua")
include("darkrp/gamemode/modules/base/sh_simplerr.lua")
include("darkrp/gamemode/modules/base/sh_playerclass.lua")
include("darkrp/gamemode/modules/base/sh_gamemode_functions.lua")
include("darkrp/gamemode/modules/base/sh_entityvars.lua")
include("darkrp/gamemode/modules/base/sh_createitems.lua")
include("darkrp/gamemode/modules/base/sh_commands.lua")
include("darkrp/gamemode/modules/base/sh_checkitems.lua")
include("darkrp/gamemode/modules/base/sv_util.lua")
include("darkrp/gamemode/modules/base/sv_purchasing.lua")
include("darkrp/gamemode/modules/base/sv_jobmodels.lua")
include("darkrp/gamemode/modules/base/sv_gamemode_functions.lua")
include("darkrp/gamemode/modules/base/sv_entityvars.lua")
include("darkrp/gamemode/modules/base/sv_data.lua")
include("darkrp/gamemode/modules/animations/sh_animations.lua")
--police stuff
include("darkrp/gamemode/modules/police/sh_init.lua")
--afk
include("darkrp/gamemode/modules/afk/sv_afk.lua")
include("darkrp/gamemode/modules/afk/sh_commands.lua")

--Compatibility
include("darkrp/gamemode/modules/allow_compatibility.lua")

DarkRP.DARKRP_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")
DarkRP.DARKRP_LOADING = nil

--DarkRP.finish() 

hook.Call("DarkRPFinishedLoading", GM)
MySQLite.initialize()
print("Loaded SV in "..(SysTime()-ss).."s")
