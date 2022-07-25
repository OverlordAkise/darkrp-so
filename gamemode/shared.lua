
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
