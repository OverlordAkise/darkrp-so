AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel(GAMEMODE.Config.moneyModel or "models/props/cs_assault/money.mdl")
    DarkRP.ValidatedPhysicsInit(self, SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    self.nodupe = true

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if self.USED or self.hasMerged then return end

    local canUse, reason = hook.Call("canDarkRPUse", nil, activator, self, caller)
    if canUse == false then
        if reason then DarkRP.notify(activator, 1, 4, reason) end
        return
    end

    self.USED = true
    local amount = self:Getamount()

    hook.Call("playerPickedUpMoney", nil, activator, amount or 0, self)

    activator:addMoney(amount or 0)
    DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("found_money", DarkRP.formatMoney(self:Getamount())))
    self:Remove()
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)

    local typ = dmg:GetDamageType()
    if bit.band(typ, bit.bor(DMG_FALL, DMG_VEHICLE, DMG_DROWN, DMG_RADIATION, DMG_PHYSGUN)) > 0 then return end

    self.USED = true
    self.hasMerged = true
    self:Remove()
end

function ENT:StartTouch(ent)
    -- the .USED var is also used in other mods for the same purpose
    if ent:GetClass() ~= "spawned_money" or self.USED or ent.USED or self.hasMerged or ent.hasMerged then return end

    -- Both hasMerged and USED are used by third party mods. Keep both in.
    ent.USED = true
    ent.hasMerged = true

    ent:Remove()
    self:Setamount(self:Getamount() + ent:Getamount())
    if GAMEMODE.Config.moneyRemoveTime and GAMEMODE.Config.moneyRemoveTime ~= 0 then
        timer.Adjust("RemoveEnt" .. self:EntIndex(), GAMEMODE.Config.moneyRemoveTime, 1, function() SafeRemoveEntity(self) end)
    end
end
