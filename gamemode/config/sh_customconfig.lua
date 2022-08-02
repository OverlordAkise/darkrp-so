-- Custom Config for SCPRP stuff

ALLOWED_STAFF_RANKS = {
  ["superadmin"] = true,
  ["admin"] = true,
  ["operator"] = true,
  ["moderator"] = true,
  ["supporter"] = true,
}

ALLOWED_PROP_SPAWNING_JOBS = {
    ["O5"] = true,
}

--Disable the Q-Menu for players, except if they are allowed to spawn props
GM.Config.disableSpawnmenu = true
--Disable the C-Menu for players
GM.Config.disableContextmenu = true
--Should staff be allowed to spawn weapons, if false only admins can spawn
GM.Config.canStaffSpawnWeapons = true
--Should staff be allowed to spawn entities
GM.Config.canStaffSpawnEntities = true
--Should staff be allowed to spawn vehicles
GM.Config.canStaffSpawnVehicles = true
--Should staff be allowed to spawn NPCs
GM.Config.canStaffSpawnNpc = true
--Should staff be allowed to spawn props
GM.Config.canStaffSpawnProps = true

