local function WARN_IT()
    print("+-----------+")
    print("| !Warning! |")
    print("+-----------+")
    print("A FUNCTION OF DARKRP's  simplerr  LIBRARY WAS CALLED!")
    print("IT IS DISABLED! CHECK WHERE ITS COMING FROM; IT WONT WORK! STACKTRACE:")
    ErrorNoHaltWithStack("Obsolete simplerr function called")
end

function runError() WARN_IT() return false, "" end
function safeCall() WARN_IT() return false, "" end
function runFile() WARN_IT() end
function wrapError() WARN_IT() end

function wrapHook(succ, err, ...) WARN_IT() return succ, err, ... end
function wrapLog(succ, err, ...) WARN_IT() return succ, err, ... end
function getLog() WARN_IT() return {} end
function clearLog() WARN_IT() end


function DarkRP.errorNoHalt(err,nr,hint)
    ErrorNoHaltWithStack(err)
    print("Hint for the above error:")
    if not hint then return end
    if istable(hint) then
        PrintTable(hint)
    else
        print(hint)
    end
end

function DarkRP.error(err,nr,hint)
    print("An error occured! Hint:")
    if hint then 
        if istable(hint) then
            PrintTable(hint)
        else
            print(hint)
        end
    else
        print("No Hint available.")
    end
    error(err)
end
