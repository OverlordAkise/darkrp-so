--The base elements are shared by every custom item
function verifyBaseSchema(tbl)
    if tbl.buttonColor and not IsColor(tbl.buttonColor) then
        return false, "The buttonColor must be a Color value!"
    end
    if tbl.category and not isstring(tbl.category) then
        return false, "The category must be a string and the name of an existing category!"
    end
    if tbl.customCheck and not isfunction(tbl.customCheck) then
        return false, "The buttonColor must be a Color value!"
    end
    if tbl.CustomCheckFailMsg and not (isfunction(tbl.CustomCheckFailMsg) or isstring(tbl.CustomCheckFailMsg)) then
        return false, "The CustomCheckFailMsg must be either a string or a function."
    end
    if tbl.sortOrder and not isnumber(tbl.sortOrder) then
        return false, "The sortOrder must be a number."
    end
    if tbl.label and not isstring(tbl.label) then
        return false, "The label must be a valid string."
    end
    return true,"",""
end

--Properties shared by anything buyable
function verifyBuySchema(tbl)
    local isCorrect, err, hint = verifyBaseSchema(tbl)
    if not isCorrect then
        return isCorrect, err, hint
    end
    if tbl.allowed and not (isnumber(tbl.allowed) or istable(tbl.allowed)) then
        return false, "The allowed field must be either an existing team or a table of existing teams.", {"Is there a job here that doesn't exist (anymore)?"}
    end
    if tbl.getPrice and not isfunction(tbl.getPrice) then
        return false, "The getPrice must be a function."
    end
    if not tbl.model or not isstring(tbl.model) then
        return false, "The model must be valid and a string."
    end
    if (not tbl.price and not tbl.getPrice) or not (isnumber(tbl.price) or isfunction(tbl.getPrice)) then
        return false, "The price must be an existing number or (for advanced users) the getPrice field must be a function."
    end
    if tbl.spawn and not isfunction(tbl.spawn) then
        return false, "The spawn must be a function."
    end
    if tbl.allowPurchaseWhileDead and not isbool(tbl.allowPurchaseWhileDead) then
        tbl.allowPurchaseWhileDead = false
    end
    return true,"",""
end

-- The command of an entity must be unique
local uniqueEntity = function(cmd, tbl)
    for _, v in pairs(DarkRPEntities) do
        if v.cmd ~= cmd then continue end

        return
            false,
            "This entity does not have a unique command.",
            {
                "There must be some other entity that has the same thing for 'cmd'.",
                "Fix this by changing the 'cmd' field of your entity to something else."
            }
    end

    return true,"",""
end

-- The command of a job must be unique
local uniqueJob = function(v, tbl)
    local job = DarkRP.getJobByCommand(v)

    if not job then return true end

    return
        false,
        "This job does not have a unique command.",
        {
            "There must be some other job that has the same command.",
            "Fix this by changing the 'command' of your job to something else."
        }
end

--Validate jobs
function DarkRP.isValidJob(tbl)
    local isCorrect, perr, phint = verifyBaseSchema(tbl)
    if not isCorrect then
        return isCorrect, perr, phint
    end
    if not tbl.color or not IsColor(tbl.color) then
        return false, "The color must be a Color value.",{"Color values look like this: Color(r, g, b, a), where r, g, b and a are numbers between 0 and 255."}
    end
    if not tbl.name or not isstring(tbl.name) then
        return false, "The name must be a valid string."
    end
    if not tbl.model or not (isstring(tbl.model) or istable(tbl.model)) then
        return false, "The model must either be a table of correct model strings or a single correct model string."
    end
    if not tbl.description or not isstring(tbl.description) then
        return false, "The description must be a string."
    end
    if tbl.weapons and not istable(tbl.weapons) then
        return false, "The weapons must be a valid table of strings.",{"Example: weapons = {\"med_kit\", \"weapon_crowbar\"},"}
    end
    if not tbl.command then
        return false, "The command must be a string."
    end
    if tbl.command then
        if not isstring(tbl.command) then
            return false, "The command must be a string."
        end
        local isValid, err, hint = uniqueJob(tbl.command)
        if not isValid then
            return isValid, err, hint
        end
    end
    if not tbl.max or not isnumber(tbl.max) or tbl.max < 0 then
        return false, "The max must be a number greater than or equal to zero.",{"Zero means infinite.","A decimal between 0 and 1 is seen as a percentage."}
    end
    if not tbl.salary or not isnumber(tbl.salary) or tbl.salary < 0 then
        return false, "The salary must be a number and it must be greater than or equal zero."
    end
    if not tbl.admin or not isnumber(tbl.admin) or tbl.admin < 0 or tbl.admin > 2 then
        return false, "The admin value must be a number and it must be greater than or equal to zero and smaller than three."
    end
    if tbl.ammo and not istable(tbl.ammo) then
        return false, "The ammo must be a table containing numbers.",{"See example on https://darkrp.miraheze.org/wiki/DarkRP:CustomJobFields"}
    end
    
        if tbl.mayor and not isbool(tbl.mayor) then
        return false, "The mayor value must be either true or false."
    end

    if tbl.chief and not isbool(tbl.chief) then
        return false, "The chief value must be either true or false."
    end

    if tbl.medic and not isbool(tbl.medic) then
        return false, "The medic value must be either true or false."
    end

    if tbl.cook and not isbool(tbl.cook) then
        return false, "The cook value must be either true or false."
    end

    if tbl.playerClass and not isstring(tbl.playerClass) then
        return false, "The playerClass must be a valid string."
    end

    if tbl.CanPlayerSuicide and not isfunction(tbl.CanPlayerSuicide) then
        return false, "The CanPlayerSuicide must be a function."
    end

    if tbl.PlayerCanPickupWeapon and not isfunction(tbl.PlayerCanPickupWeapon) then
        return false, "The PlayerCanPickupWeapon must be a function."
    end

    if tbl.PlayerDeath and not isfunction(tbl.PlayerDeath) then
        return false, "The PlayerDeath must be a function."
    end

    if tbl.PlayerLoadout and not isfunction(tbl.PlayerLoadout) then
        return false, "The PlayerLoadout must be a function."
    end

    if tbl.PlayerSelectSpawn and not isfunction(tbl.PlayerSelectSpawn) then
        return false, "The PlayerSelectSpawn must be a function."
    end

    if tbl.PlayerSetModel and not isfunction(tbl.PlayerSetModel) then
        return false, "The PlayerSetModel must be a function."
    end

    if tbl.PlayerSpawn and not isfunction(tbl.PlayerSpawn) then
        return false, "The PlayerSpawn must be a function."
    end

    if tbl.PlayerSpawnProp and not isfunction(tbl.PlayerSpawnProp) then
        return false, "The PlayerSpawnProp must be a function."
    end

    if tbl.ShowSpare1 and not isfunction(tbl.ShowSpare1) then
        return false, "The ShowSpare1 must be a function."
    end

    if tbl.ShowSpare2 and not isfunction(tbl.ShowSpare2) then
        return false, "The ShowSpare2 must be a function."
    end
    if tbl.modelScale and not isnumber(tbl.modelScale) then
        return false, "The modelScale must be a number."
    end
    if tbl.maxpocket and not isnumber(tbl.maxpocket) then
        return false, "The maxPocket must be a number."
    end
    if tbl.maps and not istable(tbl.maps) then
        return false, "The maps value must be a table of valid map names as strings."
    end
    if tbl.NeedToChangeFrom and not (isnumber(tbl.NeedToChangeFrom) or istable(tbl.NeedToChangeFrom)) then
        return false, "The NeedToChangeFrom must be either an existing team or a table of existing teams",{"Is there a job here that doesn't exist (anymore)?"}
    end
    return true,"",""
end

--Validate shipments
function DarkRP.isValidShipment(tbl)
    local isCorrect, perr, phint = verifyBuySchema(tbl)
    if not isCorrect then
        return isCorrect, perr, phint
    end
    if not tbl.entity or not isstring(tbl.entity) then
        return false, "The entity of the shipment must be a string."
    end
    if not tbl.name or not isstring(tbl.name) then
        return false, "The name must be a valid string."
    end
    if not tbl.amount or not isnumber(tbl.amount) or tbl.amount < 1 then
        return false, "The amount must be a number and it must be greater than zero."
    end
    if tbl.separate and not isbool(tbl.separate) then
        return false, "The separate field must be either true or false."
    end
    if tbl.pricesep and (not tbl.separate or isnumber(tbl.pricesep) and tbl.pricesep < 1) then
        return false, "The pricesep must be a number and it must be greater than or equal to zero."
    end
    if tbl.noship and not isbool(tbl.noship) then
        return false, "The noship must be either true or false."
    end    
    if tbl.shipmodel and not isstring(tbl.shipmodel) then
        return false, "The shipmodel must be a valid model."
    end    
    if tbl.weight and not isnumber(tbl.weight) then
        return false, "The weight must be a number."
    end    
    if tbl.spareammo and not isnumber(tbl.spareammo) then
        return false, "The spareammo must be a number."
    end    
    if tbl.clip1 and not isnumber(tbl.clip1) then
        return false, "The clip1 must be a number."
    end    
    if tbl.clip2 and not isnumber(tbl.clip2) then
        return false, "The clip2 must be a number."
    end    
    if tbl.shipmentClass and not isstring(tbl.shipmentClass) then
        return false, "The shipmentClass must be a string."
    end    
    if tbl.onBought and not isfunction(tbl.onBought) then
        return false, "The onBought must be a function."
    end
    return true,"",""
end

--Validate vehicles
function DarkRP.isValidVehicle(tbl)
    local isCorrect, perr, phint = verifyBuySchema(tbl)
    if not isCorrect then
        return isCorrect, perr, phint
    end
    if not tbl.name or not isstring(tbl.name) then
        return false, "The name field must be a string."
    end
    if tbl.distance and not isnumber(tbl.distance) then
        return false, "The distance must be a number."
    end
    if tbl.angle and not isangle(tbl.angle) then
        return false, "The angle must be a valid Angle."
    end
    return true,"",""
end

--Validate Entities
function DarkRP.isValidEntity(tbl)
    local isCorrect, perr, phint = verifyBuySchema(tbl)
    if not isCorrect then
        return isCorrect, perr, phint
    end
    if not tbl.ent or not isstring(tbl.ent) then
        return false, "The ent field must be a string."
    end
    if not tbl.max or not (isnumber(tbl.max) or isfunction(tbl.getMax)) then
        return false, "The max must be an existing number or (for advanced users) the getMax field must be a function."
    end
    if not tbl.cmd then
        return false, "The cmd field must be a valid string."
    end
    if tbl.cmd then
        if not isstring(tbl.cmd) then
            return false, "The cmd field must be a string."
        end
        local isValid, err, hint = uniqueEntity(tbl.cmd)
        if not isValid then
            return isValid, err, hint
        end
    end
    if not tbl.name or not isstring(tbl.name) then
        return false, "The name field must be a string."
    end
    if tbl.allowTools and not isbool(tbl.allowTools) then
        return false, "The allowTools must be either true or false."
    end
    if tbl.delay and not isnumber(tbl.delay) then
        return false, "The delay must be a number."
    end
    return true,"",""
end

--Validate Categories
local validCategories = {
  ["jobs"] = true,
  ["entities"] = true,
  ["shipments"] = true,
  ["weapons"] = true,
  ["vehicles"] = true,
  ["ammo"] = true
}

function DarkRP.isValidCategory(tbl)
    if not tbl.name or not isstring(tbl.name) then
        return false, "The name must be a string."
    end
    if not tbl.categorises or not isstring(tbl.categorises) or not validCategories[tbl.categorises] then
        return false, 'The categorises must be one of "jobs", "entities", "shipments", "weapons", "vehicles", "ammo"',{"Mind that this is case sensitive.","Also mind the quotation marks."}
    end
    if not tbl.startExpanded or not isbool(tbl.startExpanded) then
        return false, "The startExpanded must be either true or false."
    end
    if not tbl.color or not IsColor(tbl.color) then
        return false, "The color must be a Color value."
    end
    if tbl.canSee and not isfunction(tbl.canSee) then
        return false, "The canSee must be a function."
    end
    if tbl.sortOrder and not isnumber(tbl.sortOrder) then
        return false, "The sortOrder must be a number."
    end
    return true,"",""
end
