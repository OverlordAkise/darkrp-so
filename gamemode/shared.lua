--same for cl and sv:
hook.Run("DarkRPStartedLoading")
GM.Version = "2.7.0"
GM.Name = "DarkRP"
GM.Author = "By FPtje Falco et al."
DeriveGamemode("sandbox")
DEFINE_BASECLASS("gamemode_sandbox")
GM.Sandbox = BaseClass
GM.Config = GM.Config or {}
GM.NoLicense = GM.NoLicense or {}
DarkRP = DarkRP or {}
DarkRP.hooks = DarkRP.hooks or {}



--to replace "fp{fn.Id, true}" calls
function returnTrue()
  return true
end

--to replace fn.Id calls
function fnothing() end

function IsTeam(ply)
    if ALLOWED_STAFF_RANKS then
        if ALLOWED_STAFF_RANKS[ply:GetUserGroup()] then
            return true
        else
            return false
        end
    else
        return ply:IsAdmin()
    end
    return false
end
