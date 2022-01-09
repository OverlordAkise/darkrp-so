hook.Run("DarkRPStartedLoading")

GM.Version = "2.7.0"
GM.Name = "DarkRP"
GM.Author = "By FPtje Falco et al."

DeriveGamemode("sandbox")
DEFINE_BASECLASS("gamemode_sandbox")
GM.Sandbox = BaseClass

GM.Config = {} -- config table
GM.NoLicense = GM.NoLicense or {}

include("shared.lua")
include("config/config.lua")
include("libraries/sh_cami.lua")
include("libraries/simplerr.lua")
include("libraries/fn.lua")
--include("libraries/interfaceloader.lua")

DarkRP = {}
DarkRP.stubs = {}
DarkRP.hookStubs = {}

DarkRP.hooks = {}
DarkRP.delayedCalls = {}

DarkRP.returnsLayout = nil
DarkRP.isreturns = nil
DarkRP.parameterLayout = nil
DarkRP.isparameters = nil
DarkRP.isdeprecated = nil
DarkRP.checkStub = nil

DarkRP.hookLayout = nil
DarkRP.realm = nil
DarkRP.isreturns = function()end
DarkRP.isparameters = function()end
DarkRP.isdeprecated = function()end
DarkRP.checkStub = function()end
DarkRP.notImplemented = function()end
DarkRP.stub = function()end
DarkRP.hookStub = function()end

include("libraries/modificationloader.lua")

hook.Call("DarkRPPreLoadModules", GM)

--Chat stuff
include("darkrp/gamemode/modules/chat/sh_chatcommands.lua")
include("darkrp/gamemode/modules/chat/cl_chatlisteners.lua")
include("darkrp/gamemode/modules/chat/cl_chat.lua")
--normal order from now on
include("darkrp/gamemode/modules/workarounds/sh_workarounds.lua")
include("darkrp/gamemode/modules/voting/sh_chatcommands.lua")
include("darkrp/gamemode/modules/voting/cl_voting.lua")
include("darkrp/gamemode/modules/tipjar/cl_model.lua")
include("darkrp/gamemode/modules/tipjar/cl_frame.lua")
include("darkrp/gamemode/modules/tipjar/cl_communication.lua")
include("darkrp/gamemode/modules/sleep/sh_sleep.lua")
include("darkrp/gamemode/modules/positions/sh_commands.lua")
--police to last (fn.lua:53 not a function)
include("darkrp/gamemode/modules/playerscale/cl_playerscale.lua")
include("darkrp/gamemode/modules/money/sh_money.lua")
include("darkrp/gamemode/modules/money/sh_commands.lua")
include("darkrp/gamemode/modules/logging/cl_init.lua")
include("darkrp/gamemode/modules/language/sh_language.lua")
include("darkrp/gamemode/modules/language/sh_english.lua")
include("darkrp/gamemode/modules/jobs/sh_commands.lua")
include("darkrp/gamemode/modules/hud/sh_chatcommands.lua")
include("darkrp/gamemode/modules/hud/cl_hud.lua")
include("darkrp/gamemode/modules/hobo/cl_hobo.lua")
--hitman below base
include("darkrp/gamemode/modules/fspectate/sh_init.lua")
include("darkrp/gamemode/modules/fspectate/cl_init.lua")
include("darkrp/gamemode/modules/fpp/cl_fpp.lua")
include("darkrp/gamemode/modules/fadmin/sh_fadmin_darkrp.lua")
include("darkrp/gamemode/modules/fadmin/cl_fadmin_darkrp.lua")
include("darkrp/gamemode/modules/fadmin/cl_fadmin.lua")
include("darkrp/gamemode/modules/f4menu/cl_menuitem.lua")
include("darkrp/gamemode/modules/f4menu/cl_jobstab.lua")
include("darkrp/gamemode/modules/f4menu/cl_init.lua")
include("darkrp/gamemode/modules/f4menu/cl_frame.lua")
include("darkrp/gamemode/modules/f4menu/cl_entitiestab.lua")
include("darkrp/gamemode/modules/f4menu/cl_categories.lua")
include("darkrp/gamemode/modules/f1menu/cl_titlelabel.lua")
include("darkrp/gamemode/modules/f1menu/cl_searchbox.lua")
include("darkrp/gamemode/modules/f1menu/cl_htmlcontrols.lua")
include("darkrp/gamemode/modules/f1menu/cl_f1menupanel.lua")
include("darkrp/gamemode/modules/f1menu/cl_f1menu.lua")
include("darkrp/gamemode/modules/f1menu/cl_chatcommandspanel.lua")
include("darkrp/gamemode/modules/f1menu/cl_chatcommandlabel.lua")
include("darkrp/gamemode/modules/doorsystem/sh_doors.lua")
include("darkrp/gamemode/modules/doorsystem/cl_doors.lua")
include("darkrp/gamemode/modules/dermaskin/cl_dermaskin.lua")
include("darkrp/gamemode/modules/deathpov/cl_init.lua")
include("darkrp/gamemode/modules/cppi/sh_cppi.lua")
--Chat to the top
include("darkrp/gamemode/modules/base/sh_util.lua")
include("darkrp/gamemode/modules/base/sh_simplerr.lua")
include("darkrp/gamemode/modules/base/sh_playerclass.lua")
include("darkrp/gamemode/modules/base/sh_gamemode_functions.lua")
include("darkrp/gamemode/modules/base/sh_entityvars.lua")
include("darkrp/gamemode/modules/base/sh_createitems.lua")
include("darkrp/gamemode/modules/base/sh_commands.lua")
include("darkrp/gamemode/modules/base/sh_checkitems.lua")
include("darkrp/gamemode/modules/base/cl_util.lua")
include("darkrp/gamemode/modules/base/cl_jobmodels.lua")
include("darkrp/gamemode/modules/base/cl_gamemode_functions.lua")
include("darkrp/gamemode/modules/base/cl_fonts.lua")
include("darkrp/gamemode/modules/base/cl_entityvars.lua")
include("darkrp/gamemode/modules/base/cl_drawfunctions.lua")
include("darkrp/gamemode/modules/animations/sh_animations.lua")
--hitman stuff
include("darkrp/gamemode/modules/hitmenu/sh_init.lua")
include("darkrp/gamemode/modules/hitmenu/cl_menu.lua")
include("darkrp/gamemode/modules/hitmenu/cl_init.lua")
--police stuff
include("darkrp/gamemode/modules/police/sh_init.lua")

DarkRP.DARKRP_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")
DarkRP.DARKRP_LOADING = nil

--DarkRP.finish()

hook.Call("DarkRPFinishedLoading", GM)
