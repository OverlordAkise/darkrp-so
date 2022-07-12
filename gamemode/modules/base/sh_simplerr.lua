-- simplerrRun: Run a function with the given parameters and send any runtime errors to admins
DarkRP.simplerrRun = fc{
    fn.Snd, -- On success ignore the first return value
    simplerr.wrapError,
    simplerr.wrapHook,
    simplerr.wrapLog,
    simplerr.safeCall
}

-- error: throw a runtime error without exiting the stack
-- parameters: msg, [stackNr], [hints], [path], [line]
DarkRP.errorNoHalt = fc{
    simplerr.wrapHook,
    simplerr.wrapLog,
    simplerr.runError,
    function(msg, err, ...) return msg, err and err + 3 or 4, ... end -- Raise error level one higher
}

-- error: throw a runtime error
-- parameters: msg, [stackNr], [hints], [path], [line]
DarkRP.error = fc{
    simplerr.wrapError,
    DarkRP.errorNoHalt
}
