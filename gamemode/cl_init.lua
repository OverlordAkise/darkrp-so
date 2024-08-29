local ss = SysTime()
include("shared.lua")

include("shared.lua")
include("config/config.lua")
include("libraries/sh_cami.lua")
include("libraries/fn.lua")
include("config/sh_customconfig.lua")

include("libraries/modificationloader.lua")

hook.Call("DarkRPPreLoadModules", GM)

--Chat stuff
include("modules/chat/sh_chatcommands.lua")
include("modules/chat/cl_chat.lua")

include("modules/workarounds/sh_workarounds.lua")
include("modules/playerscale/cl_playerscale.lua")
include("modules/money/sh_money.lua")
include("modules/language/sh_language.lua")
include("modules/language/sh_english.lua")
include("modules/jobs/sh_commands.lua")
include("modules/hud/sh_chatcommands.lua")
include("modules/hud/cl_hud.lua")
include("modules/fspectate/sh_init.lua")
include("modules/fspectate/cl_init.lua")
include("modules/fpp/sh_fpp.lua")
include("modules/fpp/cl_fpp.lua")
include("modules/doorsystem/sh_doors.lua")
include("modules/doorsystem/cl_doors.lua")
include("modules/cppi/sh_cppi.lua")

include("modules/base/sh_util.lua")
include("modules/base/sh_simplerr.lua")
include("modules/base/sh_playerclass.lua")
include("modules/base/sh_gamemode_functions.lua")
include("modules/base/sh_entityvars.lua")
include("modules/base/sh_createitems.lua")
include("modules/base/sh_commands.lua")
include("modules/base/sh_checkitems.lua")
include("modules/base/cl_util.lua")
include("modules/base/cl_jobmodels.lua")
include("modules/base/cl_gamemode_functions.lua")
include("modules/base/cl_fonts.lua")
include("modules/base/cl_entityvars.lua")
include("modules/base/cl_drawfunctions.lua")
include("modules/animations/sh_animations.lua")

include("modules/afk/sh_commands.lua")
include("modules/afk/cl_afk.lua")

include("modules/allow_compatibility.lua")

DarkRP.DARKRP_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")
DarkRP.DARKRP_LOADING = nil

--DarkRP.finish()

hook.Call("DarkRPFinishedLoading", GM)
print("Loaded CL in "..(SysTime()-ss).."s")
