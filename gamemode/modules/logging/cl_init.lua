--[[---------------------------------------------------------------------------
Log a message to console
---------------------------------------------------------------------------]]
local function AdminLog(um)
    local colour = Color(um:ReadShort(), um:ReadShort(), um:ReadShort())
    local text = DarkRP.deLocalise(um:ReadString() .. "\n")

    MsgC(Color(255, 0, 0), "[" .. GAMEMODE.Name .. "] ", colour, text)

    hook.Call("DarkRPLogPrinted", nil, text, colour)
end
usermessage.Hook("DRPLogMsg", AdminLog)
