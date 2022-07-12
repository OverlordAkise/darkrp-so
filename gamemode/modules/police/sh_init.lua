local plyMeta = FindMetaTable("Player")

function plyMeta:isCP()
    return GAMEMODE.CivilProtection and GAMEMODE.CivilProtection[self:Team()] or false
end

function plyMeta:isMayor()
    return self:getJobTable().mayor
end

function plyMeta:isChief()
    return self:getJobTable().chief
end
