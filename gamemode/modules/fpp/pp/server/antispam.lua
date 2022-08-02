FPP = FPP or {}
FPP.AntiSpam = FPP.AntiSpam or {}

function FPP.AntiSpam.GhostFreeze(ent, phys)
    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ent:DrawShadow(false)
    ent.OldColor = ent.OldColor or ent:GetColor()
    ent.StartPos = ent:GetPos()
    ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a - 155))

    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
    ent.CollisionGroup = COLLISION_GROUP_WORLD

    ent.FPPAntiSpamMotionEnabled = phys:IsMoveable()
    phys:EnableMotion(false)

    ent.FPPAntiSpamIsGhosted = true
end

function FPP.UnGhost(ply, ent)
    if ent.FPPAntiSpamIsGhosted then
        ent.FPPAntiSpamIsGhosted = nil
        ent:DrawShadow(true)
        if ent.OldCollisionGroup then ent:SetCollisionGroup(ent.OldCollisionGroup) ent.OldCollisionGroup = nil end

        if ent.OldColor then
            ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a))
        end
        ent.OldColor = nil


        ent:SetCollisionGroup(COLLISION_GROUP_NONE)
        ent.CollisionGroup = COLLISION_GROUP_NONE

        local phys = ent:GetPhysicsObject()
        if phys:IsValid() then
            phys:EnableMotion(ent.FPPAntiSpamMotionEnabled)
        end
    end
end

local blacklist = {
    ["gmod_wire_indicator"] = true,
    ["phys_constraint"] = true
}
function FPP.AntiSpam.CreateEntity(ply, ent, IsDuplicate)
    local phys = ent:GetPhysicsObject()
    if not phys:IsValid() then return end
    if ent:GetClass() == "prop_physics" then FPP.AntiSpam.GhostFreeze(ent, phys) end
    local shouldRegister = hook.Call("FPP_ShouldRegisterAntiSpam", nil, ply, ent, IsDuplicate)
    if shouldRegister == false then return end

    local class = ent:GetClass()

    if not IsDuplicate and not blacklist[class] then
        ply.FPPAntiSpamCount = (ply.FPPAntiSpamCount or 0) + 1
        local time = math.Max(1, FPP.Settings.FPP_ANTISPAM1.smallpropdowngradecount)
        timer.Simple(ply.FPPAntiSpamCount / time, function()
            if IsValid(ply) then
                ply.FPPAntiSpamCount = ply.FPPAntiSpamCount - 1
            end
        end)

        if ply.FPPAntiSpamCount > FPP.Settings.FPP_ANTISPAM1.smallpropdenylimit then
            ent:Remove()
            FPP.Notify(ply, "Prop removed due to spam", false)
            return
        end
    end
end
