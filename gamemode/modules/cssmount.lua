if IsMounted("cstrike") and util.IsValidModel("models/props/cs_assault/money.mdl") then return end
hook.Add("PlayerInitialSpawn", "CSSCheck", function(ply)
    timer.Simple(5, function()
        if not IsValid(ply) then return end
        for i=1,5 do
            DarkRP.talkToPerson(ply, Color(255, 0, 0,255), "!! PLEASE INSTALL AND MOUNT CSS OR DARKRP WILL NOT WORK CORRECTLY !!")
        end
    end)
end)
