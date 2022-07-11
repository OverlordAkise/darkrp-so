local plyMeta = FindMetaTable("Player")

function plyMeta:isCP()
    return GAMEMODE.CivilProtection and GAMEMODE.CivilProtection[self:Team()] or false
end

plyMeta.isMayor = fn.Compose{fn.Curry(fn.GetValue, 2)("mayor"), plyMeta.getJobTable}
plyMeta.isChief = fn.Compose{fn.Curry(fn.GetValue, 2)("chief"), plyMeta.getJobTable}



DarkRP.declareChatCommand{
    command = "agenda",
    description = "Set the agenda.",
    delay = 1.5,
    condition = fn.Compose{fn.Not, fn.Curry(fn.Eq, 2)(nil), plyMeta.getAgenda}
}

DarkRP.declareChatCommand{
    command = "addagenda",
    description = "Add a line of text to the agenda.",
    delay = 1.5,
    condition = fn.Compose{fn.Not, fn.Curry(fn.Eq, 2)(nil), plyMeta.getAgenda}
}

DarkRP.declareChatCommand{
    command = "lottery",
    description = "Start a lottery.",
    delay = 1.5,
    condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
    command = "lockdown",
    description = "Start a lockdown. Everyone will have to stay inside.",
    delay = 1.5,
    condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
    command = "unlockdown",
    description = "Stop a lockdown.",
    delay = 1.5,
    condition = plyMeta.isMayor
}
