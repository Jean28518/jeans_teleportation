jeans_teleportation = {}

--------------------------------------------------------------------------------
-- CONFIGURATION ---------------------------------------------------------------
--------------------------------------------------------------------------------
-- See in the REAMDE.md for detailed instructions. -----------------------------

jeans_teleportation.SPAWN_POS = {x=0, y=10, z=0}
jeans_teleportation.TELEPORTATION_WITH_COORDINATES = true
jeans_teleportation.ACTIVATE_HOMEPOINTS = true -- Set it false, if players shouldnt set homepoints
jeans_teleportation.ACTIVATE_PLAYER_TP = true -- Set it to false, if players shouldn't teleport theirself to other players.
jeans_teleportation.PRICE_PER_100_BLOCKS = 5 -- Set it to zero, if pricing should be deactivated. Default is 5.
jeans_teleportation.HIGHER_PRICE_FOR_MINERS = true
jeans_teleportation.MINER_DEFINITION = -1000 -- Y-Coordinate that defines, if you are a miner (on teleporting)
jeans_teleportation.MINER_FACTOR = 1.05 -- Every 1000 Blocks deepness The price is multiplied by the Miner Factor
jeans_teleportation.ACTIVATE_TELEPORT_TO_LAST_DEATH = true -- Set it to false, if the players shouldnt port to their last death point
jeans_teleportation.PRICEHURDLE = 100 -- Above/equal this price the mod asks you, if you really want to teleport.
--------------------------------------------------------------------------------
-- MEMORY ----------------------------------------------------------------------
--------------------------------------------------------------------------------

jeans_teleportation.storage = minetest.get_mod_storage()
local homes = minetest.deserialize(jeans_teleportation.storage:get_string("homes"))
if homes == nil then
  homes = {}
end
jeans_teleportation.storage:set_string("homes", minetest.serialize(homes))

jeans_teleportation.tp_requests = {}

--------------------------------------------------------------------------------



local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/functions.lua")
dofile(modpath.."/commands.lua")





-----------------------------------------------------------------------
----- Save last death Point -------------------------------------------
-----------------------------------------------------------------------

minetest.register_on_dieplayer(function(player)
  if jeans_teleportation.ACTIVATE_TELEPORT_TO_LAST_DEATH then
    local name = player:get_player_name()
    local homes = minetest.deserialize(jeans_teleportation.storage:get_string("homes"))
    if homes[name] == nil then
      homes[name] = {}
    end
    homes[name]["death"] = player:get_pos()
    jeans_teleportation.storage:set_string("homes", minetest.serialize(homes))
    minetest.chat_send_player(name, "You died. You can get back with /tp death")
  end
end)
