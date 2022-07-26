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

function FPP.AntiSpam.DuplicatorSpam(ply)
    if FPP.Settings.FPP_ANTISPAM1.duplicatorlimit == 0 then return true end

    ply.FPPAntiSpamLastDuplicate = ply.FPPAntiSpamLastDuplicate or 0
    ply.FPPAntiSpamLastDuplicate = ply.FPPAntiSpamLastDuplicate + 1

    timer.Simple(ply.FPPAntiSpamLastDuplicate / FPP.Settings.FPP_ANTISPAM1.duplicatorlimit, function() if IsValid(ply) then ply.FPPAntiSpamLastDuplicate = ply.FPPAntiSpamLastDuplicate - 1 end end)

    if ply.FPPAntiSpamLastDuplicate >= FPP.Settings.FPP_ANTISPAM1.duplicatorlimit then
        FPP.Notify(ply, "Can't duplicate due to spam", false)
        return false
    end
    return true
end

local function e2AntiMinge()
    if not wire_expression2_funcs then return end
    local e2func = wire_expression2_funcs["applyForce(e:v)"]
    if not e2func or not e2func[3] then return end

    local applyForce = e2func[3]
    e2func[3] = function(self, args, ...)
        if not tobool(FPP.Settings.FPP_GLOBALSETTINGS1.antie2minge) then return applyForce(self, args, ...) end

        local ent = args[2][1](self, args[2]) -- Assumption: args[2][1] is a function
        if not IsValid(ent) or ent:CPPIGetOwner() ~= self.player then return end

        -- No check for whether the entity has already been no collided with players
        -- because while it would help performance,
        -- it would make it possible to get around this with constrained ents
        local ConstrainedEnts = constraint.GetAllConstrainedEntities(ent)
        if ConstrainedEnts then -- Includes original entity
            for _, v in pairs(ConstrainedEnts) do
                if IsValid(v) then
                    v:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                end
            end
        end

        return applyForce(self, args, ...)
    end
end

hook.Add("InitPostEntity", "FPP.InitializeAntiMinge", function()
    e2AntiMinge()
end)

--More crash preventing:
hook.Add("PlayerSpawnRagdoll", "FPP.AntiSpam.AntiCrash",function(ply)
    local pos = ply:GetEyeTraceNoCursor().HitPos
    for _, v in ipairs(ents.FindInSphere(pos, 30)) do
        if v:GetClass() == "func_door" then
            FPP.Notify(ply, "Can't spawn a ragdoll near doors", false)
            return false
        end
    end
end)
