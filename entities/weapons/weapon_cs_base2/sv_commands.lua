local meta = FindMetaTable("Player")
function meta:dropDRPWeapon(weapon)
    if GAMEMODE.Config.restrictdrop then
        local found = false
        for k,v in pairs(CustomShipments) do
            if v.entity == weapon:GetClass() then
                found = true
                break
            end
        end

        if not found then return end
    end

    local primAmmo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())
    self:DropWeapon(weapon) -- Drop it so the model isn't the viewmodel
    weapon:SetOwner(self)

    local ent = ents.Create("spawned_weapon")

    local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()
    model = util.IsValidModel(model) and model or "models/weapons/w_rif_ak47.mdl"

    ent:SetModel(model)
    ent:SetSkin(weapon:GetSkin() or 0)
    ent:SetWeaponClass(weapon:GetClass())
    ent.nodupe = true
    ent.clip1 = weapon:Clip1()
    ent.clip2 = weapon:Clip2()
    ent.ammoadd = primAmmo

    self:RemoveAmmo(primAmmo, weapon:GetPrimaryAmmoType())
    self:RemoveAmmo(self:GetAmmoCount(weapon:GetSecondaryAmmoType()), weapon:GetSecondaryAmmoType())

    local trace = {}
    trace.start = self:GetShootPos()
    trace.endpos = trace.start + self:GetAimVector() * 50
    trace.filter = {self, weapon, ent}

    local tr = util.TraceLine(trace)

    ent:SetPos(tr.HitPos)
    ent:Spawn()

    DarkRP.placeEntity(ent, tr, self)

    hook.Call("onDarkRPWeaponDropped", nil, self, ent, weapon)

    weapon:Remove()
end

local function DropWeapon(ply)
    local ent = ply:GetActiveWeapon()
    if not ent:IsValid() or ent:GetModel() == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
        return ""
    end

    local canDrop = hook.Call("canDropWeapon", GAMEMODE, ply, ent)
    if not canDrop then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
        return ""
    end

    ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)

    timer.Simple(1, function()
        if IsValid(ply) and IsValid(ent) and ply:Alive() and ent:GetModel() ~= "" and not IsValid(ply:GetObserverTarget()) then
            ply:dropDRPWeapon(ent)
        end
    end)
    return ""
end
DarkRP.defineChatCommand("drop", DropWeapon)
DarkRP.defineChatCommand("dropweapon", DropWeapon)
DarkRP.defineChatCommand("weapondrop", DropWeapon)
