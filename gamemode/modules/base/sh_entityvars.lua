local maxId = 0
local DarkRPVars = {}
local DarkRPVarById = {}

-- the amount of bits assigned to the value that determines which DarkRPVar we're sending/receiving
local DARKRP_ID_BITS = 8
local UNKNOWN_DARKRPVAR = 255 -- Should be equal to 2^DARKRP_ID_BITS - 1
DarkRP.DARKRP_ID_BITS = DARKRP_ID_BITS

function DarkRP.registerDarkRPVar(name, writeFn, readFn)
    maxId = maxId + 1

    -- UNKNOWN_DARKRPVAR is reserved for unknown values
    if maxId >= UNKNOWN_DARKRPVAR then DarkRP.error(string.format("Too many DarkRPVar registrations! DarkRPVar '%s' triggered this error", name), 2) end

    DarkRPVars[name] = {id = maxId, name = name, writeFn = writeFn, readFn = readFn}
    DarkRPVarById[maxId] = DarkRPVars[name]
end

-- Unknown values have unknown types and unknown identifiers, so this is sent inefficiently
local function writeUnknown(name, value)
    net.WriteUInt(UNKNOWN_DARKRPVAR, 8)
    net.WriteString(name)
    net.WriteType(value)
end

-- Read the value of a DarkRPVar that was not registered
local function readUnknown()
    return net.ReadString(), net.ReadType(net.ReadUInt(8))
end

local warningsShown = {}
local function warnRegistration(name)
    if warningsShown[name] then return end
    warningsShown[name] = true

    DarkRP.errorNoHalt(string.format("Warning! DarkRPVar '%s' wasn't registered!", name), 4)
end

function DarkRP.writeNetDarkRPVar(name, value)
    local DarkRPVar = DarkRPVars[name]
    if not DarkRPVar then
        warnRegistration(name)

        return writeUnknown(name, value)
    end

    net.WriteUInt(DarkRPVar.id, DARKRP_ID_BITS)
    return DarkRPVar.writeFn(value)
end

function DarkRP.writeNetDarkRPVarRemoval(name)
    local DarkRPVar = DarkRPVars[name]
    if not DarkRPVar then
        warnRegistration(name)

        net.WriteUInt(UNKNOWN_DARKRPVAR, 8)
        net.WriteString(name)
        return
    end

    net.WriteUInt(DarkRPVar.id, DARKRP_ID_BITS)
end

function DarkRP.readNetDarkRPVar()
    local DarkRPVarId = net.ReadUInt(DARKRP_ID_BITS)
    local DarkRPVar = DarkRPVarById[DarkRPVarId]

    if DarkRPVarId == UNKNOWN_DARKRPVAR then
        local name, value = readUnknown()

        return name, value
    end

    local val = DarkRPVar.readFn(value)

    return DarkRPVar.name, val
end

function DarkRP.readNetDarkRPVarRemoval()
    local id = net.ReadUInt(DARKRP_ID_BITS)
    -- print("DarkRP.readNetDarkRPVarRemoval id:",id)
    -- print("DarkRPVarById:",DarkRPVarById[id])
    -- print("Full Table:")
    -- PrintTable(DarkRPVarById)
    return id == 255 and net.ReadString() or DarkRPVarById[id].name
end

-- The money is a double because it accepts higher values than Int and UInt, which are undefined for >32 bits
DarkRP.registerDarkRPVar("money",         net.WriteDouble, net.ReadDouble)
DarkRP.registerDarkRPVar("salary",        fp{fn.Flip(net.WriteInt), 32}, fp{net.ReadInt, 32})
DarkRP.registerDarkRPVar("rpname",        net.WriteString, net.ReadString)
DarkRP.registerDarkRPVar("job",           net.WriteString, net.ReadString)

--RP name override
local pmeta = FindMetaTable("Player")
pmeta.SteamName = pmeta.SteamName or pmeta.Name
function pmeta:Name()
    return self:getDarkRPVar("rpname")
end
pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
