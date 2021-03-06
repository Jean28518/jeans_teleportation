# Minetest Mod: Jean's Teleportation

This Mod brings an advanced teleporting technologies to your server. Such as tp requests to other players, and paying for teleportation.

This mod does NOT overwrite any common commands as `/spawn`, `/home`, or `/teleport`. Additionaly this mod is desingned for paying for teleportation with ingame currency. But this feature can be disabled.

## Features:
- Teleporting to other players, specific positions, self set homes, or global defined telportation points automaticly in one single command
- (Optional) Teleporting to other players only works, if the other player accepts the request
- (Optional) Teleporting to specific defined coordinates (`/tp <x> <y> <z>`)
- (Optional) Teleporting to last death point
- (Optional) Unlimited custom homepoints for players
- (Optional) Integration of Jean's Economy. Teleporting will cost something depending on the teleport distance
- (Optional) Higher teleporting prices for miners.

## Commands:
- `/tp spawn` Teleporting to the spawn of the server.
- `/tp <player>` Sending a teleportation request to another player. That has to be accepted by `/tp_yes`, or can be canceld by the initior with `/tp_canc`
- `/tp <x> <y> <z>` Teleporting to a specific location. This feature can be disabled. See below for instructions.
- `/tp_add <home_name>` Set a custom homepoint at the current position. You can set unlimited homepoints. This feature can be disabled. See below for instructions.
- `/tp <home_name>` Teleporting to a custom home point.
- `/tp death` Teleports your to your last death point.
- `/tp_list` See all your custom homepoints
- `/tp_del <home_name>` Deleting a custom home point.
- `/tp <your_globally_defined_teleportation_point>` You can define your own global teleportation points. (See below for instructions). For example: `/tp adminshop`, `/tp libary`, ....
- `/tp_help` Displays the ingame commands. Only the commands are shown, wich are activated.

## Configuration:
You can configure some functions and definitions in the init.lua file. You are able to configure:
- the spawnpoint in line 8.
- other Custom Public Points. Please read the comments there for specific instructions from `functions.lua:10`.
- whether teleporting to specific coordinates is allowed or not (Line 7)
- if players can save their own Home Points or not with `/tp_add <home_name>` (Line 8)
- if players can teleport to eachother with `/tp <player>`(Line 9)

### Pricing:
When the Mod Jean's Economy can be found by the mod, pricing is activated by default. Otherwise you don't have to keep attention to it, and pricing is disabled automaticly. When you have Jean's Economy activated, but dont want to have the pricing activated, you can disable this by setting `PRICE_PER_100_BLOCKS = 0` in Line 12. For a teleportation with more than 100 Money, you will be asked, if you want to teleport with such a high price. You can confirm with `/tp_confirm`.

Also a feature is implemented, that (real) miners have to pay higher prices by getting far in the underground, or getting aut of it. You can configure/disable this in the Lines 13 - 15. The price grows exponentially by getting deeper.
