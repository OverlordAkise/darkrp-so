DarkRP.registerDarkRPVar("AFK", net.WriteBit, fn.Compose{tobool, net.ReadBit})

DarkRP.declareChatCommand{
    command = "afk",
    description = "Go AFK",
    delay = 1.5
}
