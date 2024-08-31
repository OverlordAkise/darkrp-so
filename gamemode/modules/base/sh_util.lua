--[[---------------------------------------------------------------------------
Utility functions
---------------------------------------------------------------------------]]

local vector = FindMetaTable("Vector")
local meta = FindMetaTable("Player")

--[[---------------------------------------------------------------------------
Decides whether the vector could be seen by the player if they were to look at it
---------------------------------------------------------------------------]]
function vector:isInSight(filter, ply)
    ply = ply or LocalPlayer()
    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = self
    trace.filter = filter
    trace.mask = -1
    local TheTrace = util.TraceLine(trace)

    return not TheTrace.Hit, TheTrace.HitPos
end

--[[---------------------------------------------------------------------------
Turn a money amount into a pretty string
---------------------------------------------------------------------------]]
local function attachCurrency(str)
    local config = GAMEMODE.Config
    return config.currencyLeft and config.currency .. str or str .. config.currency
end

function DarkRP.formatMoney(n)
    if not n or not tonumber(n) then return attachCurrency("0") end
    return attachCurrency(string.Comma(n))
end

--[[---------------------------------------------------------------------------
Find a player based on given information
---------------------------------------------------------------------------]]
function DarkRP.findPlayer(info)
    if not info or info == "" then return nil end
    local pls = player.GetAll()

    for k = 1, #pls do -- Proven to be faster than pairs loop.
        local v = pls[k]
        if tonumber(info) == v:UserID() then
            return v
        end

        if info == v:SteamID() then
            return v
        end

        if string.find(string.lower(v:Nick()), string.lower(tostring(info)), 1, true) ~= nil then
            return v
        end

        if string.find(string.lower(v:SteamName()), string.lower(tostring(info)), 1, true) ~= nil then
            return v
        end
    end
    return nil
end

function meta:getEyeSightHitEntity(searchDistance, hitDistance, filter)
    searchDistance = searchDistance or 100
    hitDistance = (hitDistance or 15) * (hitDistance or 15)

    filter = filter or function(p) return p:IsPlayer() and p ~= self end

    self:LagCompensation(true)

    local shootPos = self:GetShootPos()
    local entities = ents.FindInSphere(shootPos, searchDistance)
    local aimvec = self:GetAimVector()

    local smallestDistance = math.huge
    local foundEnt

    for _, ent in pairs(entities) do
        if not IsValid(ent) or filter(ent) == false then continue end

        local center = ent:GetPos()

        -- project the center vector on the aim vector
        local projected = shootPos + (center - shootPos):Dot(aimvec) * aimvec

        if aimvec:Dot((projected - shootPos):GetNormalized()) < 0 then continue end

        -- the point on the model that has the smallest distance to your line of sight
        local nearestPoint = ent:NearestPoint(projected)
        local distance = nearestPoint:DistToSqr(projected)

        if distance < smallestDistance then
            local trace = {
                start = self:GetShootPos(),
                endpos = nearestPoint,
                filter = {self, ent}
            }
            local traceLine = util.TraceLine(trace)
            if traceLine.Hit then continue end

            smallestDistance = distance
            foundEnt = ent
        end
    end

    self:LagCompensation(false)

    if smallestDistance < hitDistance then
        return foundEnt, math.sqrt(smallestDistance)
    end

    return nil
end

function meta:hasDarkRPPrivilege(priv)
    return self:IsAdmin()
end

function DarkRP.nickSortedPlayers()
    local plys = player.GetAll()
    table.sort(plys, function(a,b) return a:Nick() < b:Nick() end)
    return plys
end

--Convert a string to a table of arguments
local bitlshift, stringgmatch, stringsub, tableinsert = bit.lshift, string.gmatch, string.sub, table.insert
function DarkRP.explodeArg(arg)
    local args = {}

    local from, to, diff = 1, 0, 0
    local inQuotes, wasQuotes = false, false

    for c in stringgmatch(arg, '.') do
        to = to + 1

        if c == '"' then
            inQuotes = not inQuotes
            wasQuotes = true

            continue
        end

        if c == ' ' and not inQuotes then
            diff = wasQuotes and 1 or 0
            wasQuotes = false
            tableinsert(args, stringsub(arg, from + diff, to - 1 - diff))
            from = to + 1
        end
    end
    diff = wasQuotes and 1 or 0

    if from ~= to + 1 then tableinsert(args, stringsub(arg, from + diff, to + 1 - bitlshift(diff, 1))) end

    return args
end

function DarkRP.ValidatedPhysicsInit(ent, solidType)
    solidType = solidType or SOLID_VPHYSICS
    if ent:PhysicsInit(solidType) then return true end
    return false
end

function DarkRP.toInt(value)
    value = tonumber(value)
    return value and math.floor(value)
end

function meta:isMedic()
    return self:getJobTable().medic
end
