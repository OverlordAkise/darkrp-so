FPP = FPP or {}
util.AddNetworkString("FPP_Notify")

FPP.Blocked = FPP.Blocked or {}
FPP.Blocked.Physgun1 = FPP.Blocked.Physgun1 or {}
FPP.Blocked.Spawning1 = FPP.Blocked.Spawning1 or {}
FPP.Blocked.Gravgun1 = FPP.Blocked.Gravgun1 or {}
FPP.Blocked.Toolgun1 = FPP.Blocked.Toolgun1 or {}
FPP.BlockedModels = FPP.BlockedModels or {}

function FPP.Notify(ply, text, bool)
    if ply:EntIndex() == 0 then
        ServerLog(text)
        return
    end
    net.Start("FPP_Notify")
        net.WriteString(text)
        net.WriteBool(bool)
    net.Send(ply)
    ply:PrintMessage(HUD_PRINTCONSOLE, text)
end

function FPP.NotifyAll(text, bool)
    net.Start("FPP_Notify")
        net.WriteString(text)
        net.WriteBool(bool)
    net.Broadcast()
    for _, ply in ipairs(player.GetAll()) do
        ply:PrintMessage(HUD_PRINTCONSOLE, text)
    end
end

FPP.Blocked.Physgun1 = {
    ["func_breakable_surf"] = true,
    ["func_brush"] = true,
    ["func_button"] = true,
    ["func_door"] = true,
    ["prop_door_rotating"] = true,
    ["func_door_rotating"] = true
}

FPP.Blocked.Spawning1 = {
    ["func_breakable_surf"] = true,
    ["player"] = true,
    ["func_door"] = true,
    ["prop_door_rotating"] = true,
    ["func_door_rotating"] = true,
    ["ent_explosivegrenade"] = true,
    ["ent_mad_grenade"] = true,
    ["ent_flashgrenade"] = true,
    ["gmod_wire_field_device"] = true
}
FPP.Blocked.Gravgun1 = {
    ["func_breakable_surf"] = true,
    ["vehicle_"] = true
}
FPP.Blocked.Toolgun1 = {
    ["func_breakable_surf"] = true,
    ["func_button"] = true,
    ["player"] = true,
    ["func_door"] = true,
    ["prop_door_rotating"] = true,
    ["func_door_rotating"] = true
}

local function getIntendedBlockedModels(model, ent)
    model = string.Replace(string.lower(model), "\\", "/")

    if not IsValid(ent) then return {model} end
    if ent:GetClass() == "prop_effect" then return {ent.AttachedEntity:GetModel()} end
    if model ~= ent:GetModel() then return {model, ent:GetModel()} end
    return {model}
end

concommand.Add("FPP_AddBlockedModel", function(ply, cmd, args)
    if not IsTeam(ply) then return end
    if not args[1] then FPP.Notify(ply, "FPP_AddBlockedModel: Model not given", false) return end
    local models = getIntendedBlockedModels(args[1], tonumber(args[2]) and Entity(args[2]) or nil)

    for _, model in pairs(models) do
        FPP.BlockedModels[model] = true
        FPP.Notify(ply, "Model removed from blacklist!", false)
        FPP.Notify(ply, "This does not save over restarts! Edit the lua file!", false)
    end
end)

concommand.Add("FPP_RemoveBlockedModel", function(ply, cmd, args)
    if not IsTeam(ply) then return end
    if not args[1] then FPP.Notify(ply, "FPP_RemoveBlockedModel: Model not given", false) return end
    local models = getIntendedBlockedModels(args[1], tonumber(args[2]) and Entity(args[2]) or nil)

    for _, model in pairs(models) do
        FPP.BlockedModels[model] = nil
        FPP.Notify(ply, "Model removed from blacklist!", false)
        FPP.Notify(ply, "This does not save over restarts! Edit the lua file!", false)
    end
end)
