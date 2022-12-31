# DarkRP-SO

## DarkRP - SCPRP Optimized

This is the darkrp gamemode but without a lot of the features. It removes everything that is not needed for SCPRP, which means that nearly half of the codebase is missing.

For the "real" darkrp gamemode please visit https://github.com/FPtje/DarkRP

This addon should be installed *AFTER* you set up a running SCPRP server because many checks and fancy "error" prints have been removed.

Compatibility is provided via the "allow_compatibility.lua" file. This means nothing should break if an addon needs something that got removed.

# Major changes

 - Removed the darkrp hud, scoreboard, f4menu, etc. (nearly all UIs)
 - Removed Hitman, Police, Mayor, Laws, Voting, Demotes, DoorTax, GunDealer, Shipments, VoteOnlyJobs
 - Removed the disjointset, simplerr and tablecheck libraries (recoded these parts)
 - Removed mayor's lockdown command
 - Removed wanted/warrants, jails, jailpositions arrest-baton
 - FPP has been minified, if you need your users to spawn props this could be a problem
 - Rewritten umsg to net messages

