local plyMeta = FindMetaTable("Player")
DarkRP.chatCommands = DarkRP.chatCommands or {}

local validChatCommand = {
    command = isstring,
    description = isstring,
    condition = function(input) return input == nil or isfunction(input) end,
    delay = isnumber,
    tableArgs = function(input) return input == nil or isbool(input) end,
}

local checkChatCommand = function(tbl)
    for k in pairs(validChatCommand) do
        if not validChatCommand[k](tbl[k]) then
            return false, k
        end
    end
    return true
end

function DarkRP.declareChatCommand(tbl)
    local valid, element = checkChatCommand(tbl)
    if not valid then
        DarkRP.error("Incorrect chat command! " .. element .. " is invalid!", 2)
    end

    tbl.command = string.lower(tbl.command)
    DarkRP.chatCommands[tbl.command] = DarkRP.chatCommands[tbl.command] or tbl
    for k, v in pairs(tbl) do
        DarkRP.chatCommands[tbl.command][k] = v
    end
end

function DarkRP.removeChatCommand(command)
    DarkRP.chatCommands[string.lower(command)] = nil
end

function DarkRP.chatCommandAlias(command, ...)
    local name
    for k, v in pairs{...} do
        name = string.lower(v)

        DarkRP.chatCommands[name] = {command = name}
        setmetatable(DarkRP.chatCommands[name], {
            __index = DarkRP.chatCommands[command]
        })
    end
end

function DarkRP.getChatCommand(command)
    return DarkRP.chatCommands[string.lower(command)]
end

function DarkRP.getChatCommands()
    return DarkRP.chatCommands
end

function DarkRP.getSortedChatCommands()
    local tbl = fn.Compose{table.ClearKeys, table.Copy, DarkRP.getChatCommands}()
    table.SortByMember(tbl, "command", true)

    return tbl
end

-- chat commands that have been defined, but not declared
DarkRP.getIncompleteChatCommands = function() return {} end
