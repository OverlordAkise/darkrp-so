DarkRP.chatCommands = DarkRP.chatCommands or {}

--This only sets description but not actual command logic
function DarkRP.declareChatCommand() end

function DarkRP.removeChatCommand(command)
    DarkRP.chatCommands[string.lower(command)] = nil
end

function DarkRP.getChatCommand(command)
    return DarkRP.chatCommands[string.lower(command)]
end

function DarkRP.getChatCommands()
    return DarkRP.chatCommands
end

function DarkRP.getSortedChatCommands()
    local tbl = table.ClearKeys(table.Copy(DarkRP.getChatCommands))
    table.SortByMember(tbl, "command", true)
    return tbl
end
