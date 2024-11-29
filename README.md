# DarkRP-SO

## DarkRP - SCPRP Optimized

This is the darkrp gamemode but without a lot of the features. It removes everything that is not needed for SCPRP, which means that nearly half of the codebase is missing.

For the real, original darkrp gamemode please visit https://github.com/FPtje/DarkRP

This addon should be installed *AFTER* you set up a running SCPRP server because many checks and fancy error prints have been removed.

Compatibility is provided via the "allow_compatibility.lua" file. This means nothing should break if an addon needs something that got removed.

# Major changes

Fspectate and FPP have been removed, if you need them please get them from the workshop or github again.

Do NOT install this if you need any of the following that have been removed:

 - Removed the darkrp hud, scoreboard, f4menu, etc. (nearly all UIs)
 - Removed Hitman, Police, Mayor, Laws, Voting, Demotes, DoorTax, GunDealer, Shipments, VoteOnlyJobs
 - Removed the disjointset, simplerr and tablecheck libraries (recoded these parts)
 - Removed mayor's lockdown command
 - Removed wanted/warrants, jails, jailpositions arrest-baton
 - Rewritten umsg to net messages

Features Removed:

 - NeedsToChangeFrom job logic,  RemoveEntitiesOnJobChange logic


# FAQ

Q: Why did you change specific functions or removed them?  
A: I have helped many many servers and still have 1.6mil (!) lua files laying around. I search through these files and check if any addon or script uses a functionality, and if i don't find any then i will remove the functionality.