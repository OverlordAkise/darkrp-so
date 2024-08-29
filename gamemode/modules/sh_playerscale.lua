local minHull = Vector(-16, -16, 0)
if CLIENT then
    net.Receive("darkrp_playerscale",function(len,ply)
        local ply = net.ReadEntity()
        local scale = net.ReadFloat()
        if not IsValid(ply) then return end
        ply:SetModelScale(scale, 1)
        ply:SetHull(minHull, Vector(16, 16, 72 * scale))
    end)
else --if SERVER then
    util.AddNetworkString("darkrp_playerscale")
    local function setScale(ply, scale)
        ply:SetModelScale(scale, 0)
        ply:SetHull(minHull, Vector(16, 16, 72 * scale))
        net.Start("darkrp_playerscale")
            net.WriteEntity(ply)
            net.WriteFloat(scale)
        net.Broadcast()
    end
    hook.Add("PlayerLoadout", "playerScale", function(ply)
        local Team = ply:Team()
        if not RPExtraTeams[Team] or not tonumber(RPExtraTeams[Team].modelScale) then
            setScale(ply, 1)
            return
        end

        local modelScale = tonumber(RPExtraTeams[Team].modelScale)

        setScale(ply, modelScale)
    end)
end
