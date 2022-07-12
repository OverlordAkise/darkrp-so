--[[---------------------------------------------------------
 Mayor stuff
 ---------------------------------------------------------]]
local LotteryPeople = {}
local LotteryON = false
local LotteryAmount = 0
local CanLottery = CurTime()
local function EnterLottery(answer, ent, initiator, target, TimeIsUp)
    local hasEntered = table.HasValue(LotteryPeople, target)
    if tobool(answer) and not hasEntered then
        if not target:canAfford(LotteryAmount) then
            DarkRP.notify(target, 1, 4, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("lottery")))

            return
        end
        table.insert(LotteryPeople, target)
        target:addMoney(-LotteryAmount)
        DarkRP.notify(target, 0,4, DarkRP.getPhrase("lottery_entered", DarkRP.formatMoney(LotteryAmount)))
        hook.Run("playerEnteredLottery", target)
    elseif IsValid(target) and answer ~= nil and not hasEntered then
        DarkRP.notify(target, 1,4, DarkRP.getPhrase("lottery_not_entered", target:Nick()))
    end

    if TimeIsUp then
        LotteryON = false
        CanLottery = CurTime() + 60

        for i = #LotteryPeople, 1, -1 do
            if not IsValid(LotteryPeople[i]) then table.remove(LotteryPeople, i) end
        end

        if table.IsEmpty(LotteryPeople) then
            DarkRP.notifyAll(1, 4, DarkRP.getPhrase("lottery_noone_entered"))
            hook.Run("lotteryEnded", LotteryPeople)
            return
        end
        local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
        local amt = #LotteryPeople * LotteryAmount
        hook.Run("lotteryEnded", LotteryPeople, chosen, amt)
        chosen:addMoney(amt)
        DarkRP.notifyAll(0, 10, DarkRP.getPhrase("lottery_won", chosen:Nick(), DarkRP.formatMoney(amt)))
    end
end

local function DoLottery(ply, amount)
    if not ply:isMayor() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", "/lottery"))
        return ""
    end

    if not GAMEMODE.Config.lottery then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", "/lottery", ""))
        return ""
    end

    if player.GetCount() <= 2 then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("too_few_players_for_lottery", 2))
        return ""
    end

    if LotteryON then
        DarkRP.notify(ply, 1, 6, DarkRP.getPhrase("lottery_ongoing"))
        return ""
    end

    if CanLottery > CurTime() then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("have_to_wait", tostring(CanLottery - CurTime()), "/lottery"))
        return ""
    end

    amount = DarkRP.toInt(amount)
    if not amount then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("lottery_please_specify_an_entry_cost", DarkRP.formatMoney(GAMEMODE.Config.minlotterycost), DarkRP.formatMoney(GAMEMODE.Config.maxlotterycost)))
        return ""
    end

    LotteryAmount = math.Clamp(amount, GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost)

    hook.Run("lotteryStarted", ply, LotteryAmount)

    LotteryON = true
    LotteryPeople = {}

    local phrase = DarkRP.getPhrase("lottery_has_started", DarkRP.formatMoney(LotteryAmount))
    for k, v in ipairs(player.GetAll()) do
        if v ~= ply then
            DarkRP.createQuestion(phrase, DarkRP.getPhrase("lottery") .. tostring(k), v, 30, EnterLottery, ply, v)
        end
    end
    timer.Create("Lottery", 30, 1, function() EnterLottery(nil, nil, nil, nil, true) end)
    return ""
end
DarkRP.defineChatCommand("lottery", DoLottery, 1)


local lastLockdown = -math.huge
function DarkRP.lockdown(ply)
    local show = ply:EntIndex() == 0 and print or fp{DarkRP.notify, ply, 1, 4}
    if GetGlobalBool("DarkRP_LockDown") then
        show(DarkRP.getPhrase("unable", "/lockdown", DarkRP.getPhrase("stop_lockdown")))
        return ""
    end

    if ply:EntIndex() ~= 0 and not ply:isMayor() then
        show(DarkRP.getPhrase("incorrect_job", "/lockdown", ""))
        return ""
    end

    if not GAMEMODE.Config.lockdown then
        show(ply, 1, 4, DarkRP.getPhrase("disabled", "lockdown", ""))
        return ""
    end

    if lastLockdown > CurTime() - GAMEMODE.Config.lockdowndelay then
        show(DarkRP.getPhrase("wait_with_that"))
        return ""
    end

    for _, v in ipairs(player.GetAll()) do
        v:ConCommand("play " .. GAMEMODE.Config.lockdownsound .. "\n")
    end

    DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_started"))
    SetGlobalBool("DarkRP_LockDown", true)
    DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_started"))

    hook.Run("lockdownStarted", ply)

    return ""
end
DarkRP.defineChatCommand("lockdown", DarkRP.lockdown)

function DarkRP.unLockdown(ply)
    local show = ply:EntIndex() == 0 and print or fp{DarkRP.notify, ply, 1, 4}

    if not GetGlobalBool("DarkRP_LockDown") then
        show(DarkRP.getPhrase("unable", "/unlockdown", DarkRP.getPhrase("lockdown_ended")))
        return ""
    end

    if ply:EntIndex() ~= 0 and not ply:isMayor() then
        show(DarkRP.getPhrase("incorrect_job", "/unlockdown", ""))
        return ""
    end

    DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_ended"))
    DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_ended"))
    SetGlobalBool("DarkRP_LockDown", false)

    lastLockdown = CurTime()

    hook.Run("lockdownEnded", ply)

    return ""
end
DarkRP.defineChatCommand("unlockdown", DarkRP.unLockdown)
