FAdmin.Messages = {}

FAdmin.Messages.MsgTypes = {
    ERROR = {TEXTURE = "icon16/exclamation.png", COLOR = Color(255,180,0,80)},
    NOTIFY = {TEXTURE = "vgui/notices/error", COLOR = Color(255,255,0,80)},
    QUESTION = {TEXTURE = "vgui/notices/hint", COLOR = Color(0,0,255,80)},
    GOOD = {TEXTURE = "icon16/tick.png", COLOR = Color(0,255,0,80)},
    BAD = {TEXTURE = "icon16/cross.png", COLOR = Color(255,0,0,80)}
}
FAdmin.Messages.MsgTypesByName = {
    ERROR = 1,
    NOTIFY = 2,
    QUESTION = 3,
    GOOD = 4,
    BAD = 5,
}

function FAdmin.PlayerName(ply)
    if CLIENT and ply == LocalPlayer() then return "you" end

    return isstring(ply) and ply or not IsValid(ply) and "unknown" or ply:EntIndex() == 0 and "Console" or ply:Nick()
end

function FAdmin.TargetsToString(targets)
    if not istable(targets) then
        return FAdmin.PlayerName(targets)
    end

    local targetCount = #targets
    if targetCount == 0 then
        return "no one"
    end

    if targetCount == player.GetCount() and targetCount ~= 1 then
        return "everyone"
    end

    targets = table.Copy(targets)
    local names = fn.Map(FAdmin.PlayerName, targets)

    if #names == 1 then
        return names[1]
    end

    return table.concat(names, ", ", 1, #names - 1) .. " and " .. names[#names]
end

FAdmin.Notifications = {}

local notifList = {
    ["everyone"] = true,
    ["admins"] = true,
    ["superadmins"] = true,
    ["self"] = true,
    ["targets"] = true,
    ["involved"] = true,
    ["involved+admins"] = true,
    ["involved+superadmins"] = true
}

local notifTypes = {
  ["ERROR"] = true,
  ["NOTIFY"] = true,
  ["QUESTION"] = true,
  ["GOOD"] = true,
  ["BAD"] = true
}

function isValidNotification(tbl)
    if not tbl.name or not isstring(tbl.name) then
        return false, "The name must be a string!"
    end
    if tbl.hasTarget and not isbool(tbl.hasTarget) then
        return false, "hasTarget must either be true, false or nil!"
    end
    if not tbl.receivers or not (isfunction(tbl.receivers) or notifList[tbl.receivers]) then
        return false, "receivers must either be a function returning a table of players or one of 'admins', 'superadmins', 'everyone', 'self', 'targets', 'involved', 'involved+admins', 'involved+superadmins'"
    end
    if not tbl.message or not isstring(tbl.message) then
        return false, "The message field must be a table of strings! with special strings 'targets', 'you', 'instigator', 'extraInfo.#', with # a number."
    end
    if not tbl.msgType then
        tbl.msgType = "NOTIFY"
    end
    if not isstring(tbl.msgType) or not notifTypes[tbl.msgType] then
        return false, "msgType must be one of 'ERROR', 'NOTIFY', 'QUESTION', 'GOOD', 'BAD'"
    end
    if tbl.writeExtraInfo and not isfunction(tbl.writeExtraInfo) then
        return false, "writeExtraInfo must be a function"
    end
    if tbl.readExtraInfo and not isfunction(tbl.readExtraInfo) then
        return false, "readExtraInfo must be a function"
    end
    if tbl.extraInfoColors and not IsColor(tbl.extraInfoColors) then
        return false, "extraInfoColors must be a table of colours!"
    end
    if not tbl.logging then tbl.logging = true end
    if tbl.logging and not isbool(tbl.logging) then
        return false, "logging must be a boolean!"
    end
    return true,""
end


FAdmin.NotificationNames = {}

function FAdmin.Messages.RegisterNotification(tbl)
    local correct, err = isValidNotification(tbl)

    if not correct then
        error(string.format("Incorrect notification format for notification '%s'!\n\n%s", istable(tbl) and tbl.name or "unknown", err), 2)
    end

    local key = table.insert(FAdmin.Notifications, tbl)
    FAdmin.NotificationNames[tbl.name] = key

    return key
end
