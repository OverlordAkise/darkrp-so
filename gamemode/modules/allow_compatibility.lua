local plymeta = FindMetaTable("Player")



-- Hitman
function DarkRP.addHitmanTeam() end
function DarkRP.getHitmanTeams() return {} end
function DarkRP.getHits() return {} end
--sh
function plymeta:isHitman() return false end
function plymeta:hasHit() return false end
function plymeta:getHitPrice() return 0 end
function plymeta:getHitTarget() return nil end
--sv
if SERVER then
    function plymeta:setHitCustomer() end
    function plymeta:setHitPrice() end
    function plymeta:setHitTarget() end
    function plymeta:abortHit() end
    function plymeta:finishHit() end
    function plymeta:requestHit() end
    function plymeta:placeHit() end
    function plymeta:getHitCustomer() return nil end
end
--cl
if CLIENT then
    function DarkRP.openHitMenu() end
    function plymeta:stopHitInfo() end
end
--DarkRPVars
DarkRP.registerDarkRPVar("hasHit", net.WriteBit, fn.Compose{tobool, net.ReadBit})
DarkRP.registerDarkRPVar("hitTarget", net.WriteEntity, net.ReadEntity)
DarkRP.registerDarkRPVar("hitPrice", fn.Curry(fn.Flip(net.WriteInt), 2)(32), fn.Partial(net.ReadInt, 32))
DarkRP.registerDarkRPVar("lastHitTime", fn.Curry(fn.Flip(net.WriteInt), 2)(32), fn.Partial(net.ReadInt, 32))



--Police
--sh
function plymeta:getWantedReason() return "" end
function plymeta:isWanted() return false end
function plymeta:isArrested() return false end
--sv
if SERVER then
    function plymeta:unWanted() end
    function plymeta:wanted() end
    function plymeta:requestWarrant() end
    function plymeta:warrant() end
    function plymeta:unWarrant() end
    function plymeta:arrest() end
    function plymeta:unArrest() end
end
DarkRP.registerDarkRPVar("HasGunlicense", net.WriteBit, fc{tobool, net.ReadBit})
DarkRP.registerDarkRPVar("Arrested",      net.WriteBit, fc{tobool, net.ReadBit})
DarkRP.registerDarkRPVar("wanted",        net.WriteBit, fc{tobool, net.ReadBit})
DarkRP.registerDarkRPVar("wantedReason",  net.WriteString, net.ReadString)



--Jobs
TEAM_HOBO = -1
TEAM_GUN = -1

print("[luctus_so] Loaded backwards compatibility")
