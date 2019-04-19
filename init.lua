--------------------------------------------------------------------------------
-- CONFIGURATION ---------------------------------------------------------------
--------------------------------------------------------------------------------
-- See in the REAMDE.md for detailed instructions. -----------------------------

local SPAWN_POS = minetest.settings:get("static_spawnpoint") or {x=0, y=10, z=0}
local TELEPORTATION_WITH_COORDINATES = true
local ACTIVATE_HOMEPOINTS = true -- Set it false, if players shouldnt set homepoints
local PRICE_PER_100_BLOCKS = 10 -- Set it to zero, if pricing should be deactivated
local HIGHER_PRICE_FOR_MINERS = true
local MINER_DEFINITION = -1000 -- Y-Coordinate that defines, if you are a miner (on teleporting)
local MINER_FACTOR = 1.05 -- Every 1000 Blocks deepness The price is multiplied by the Miner Factor

--------------------------------------------------------------------------------
-- MEMORY ----------------------------------------------------------------------
--------------------------------------------------------------------------------

local storage = minetest.get_mod_storage()
local homes = minetest.deserialize(storage:get_string("homes"))
if homes == nil then
  homes = {}
end
storage:set_string("homes", minetest.serialize(homes))

local tp_requests = {}

--------------------------------------------------------------------------------

local jeans_economy = false
if minetest.get_modpath("jeans_economy") then jeans_economy = true end

--------------------------------------------------------------------------------
-- COMMANDS --------------------------------------------------------------------
--------------------------------------------------------------------------------

minetest.register_chatcommand("tp", {
  privs = {
    interact = true,
  },
  func = function(name, param)
    local dest_pos = jeans_teleportation_analyze_command(name, param)
    if dest_pos == nil then
      minetest.chat_send_player(name, "Correct use: /tp <x> <y> <z>, /tp <player>, /tp spawn, /tp <home>")
    elseif dest_pos == "player" then
      minetest.chat_send_player(name, "Request sended. You can cancel your request with /tp_canc")
    else
      jeans_teleportation_teleport(name, dest_pos)
    end

  end
})

if ACTIVATE_HOMEPOINTS then
  minetest.register_chatcommand("tp_set", {
    privs = {
      interact = true,
    },
    func = function(name, param)
      local homes = minetest.deserialize(storage:get_string("homes"))
      if homes[name] == nil then
        homes[name] = {}
      end
      homes[name][param] = minetest.get_player_by_name(name):get_pos()
      storage:set_string("homes", minetest.serialize(homes))
      minetest.chat_send_player(name, "Home successfully set!")
    end
  })
end

minetest.register_chatcommand("tp_del", {
  privs = {
    interact = true,
  },
  func = function(name, param)
    local homes = minetest.deserialize(storage:get_string("homes"))
    if homes[name] == nil then
      homes[name] = {}
    end
    homes[name][param] = nil
    minetest.chat_send_player(name, "Home successfully deleted!")
    storage:set_string("homes", minetest.serialize(homes))
  end
})
minetest.register_chatcommand("tp_list", {
  privs = {
    interact = true,
  },
  func = function(name, param)
    local homes = minetest.deserialize(storage:get_string("homes"))
    local homes_string = ""
    if homes[name] ~= nil then
      for home_name, home_pos in pairs(homes[name]) do
        homes_string = homes_string .. home_name.." "
      end
    end
    minetest.chat_send_player(name, homes_string)
  end
})

minetest.register_chatcommand("tp_yes", {
  privs = {
    interact = true,
  },
  func = function(name, param)
    if tp_requests[name] ~= nil then
      jeans_teleportation_teleport(tp_requests[name], minetest.get_player_by_name(name):get_pos())
      minetest.chat_send_player(name, "Teleporting "..tp_requests[name].." to you...")
      tp_requests[name] = nil

    end
  end
})

minetest.register_chatcommand("tp_canc", {
  privs = {
    interact = true,
  },
  func = function(name, param)
    for k, v in pairs(tp_requests) do
      if v == name then
        tp_requests[k] = nil
        minetest.chat_send_player(k, v.." don't want anymore to teleport itself to you")
      end
    end
    minetest.chat_send_player(name, "Your requests where deleted")
  end
})

--------------------------------------------------------------------------------
-- FUNCTIONS -------------------------------------------------------------------
--------------------------------------------------------------------------------

function jeans_teleportation_analyze_command(playername, param)
  if param == "spawn" then
    return SPAWN_POS
  end
  -- YOU CAN COMMENT OUT THIS SECTION AND DEFINE YOUR OWN GLOBAL TP POINTS.
  -- (OF COURSE YOU CAN duplicate this three lines of code how many times you want)
  -- if param == "YOUR TP NAME" then
  --   return {x = 0, y = 0, z = 0}
  -- end

  local homes = minetest.deserialize(storage:get_string("homes"))
  if homes[playername] ~= nil then
    for home_name, home_pos in pairs(homes[playername]) do
      if param == home_name then
        return home_pos
      end
    end
  end
  if minetest.get_player_by_name(param) then
    tp_requests[param] = playername -- minetest.get_player_by_name(param):get_pos()
    minetest.chat_send_player(param, playername.." wants to teleport itself to you. Accept with /tp_yes")
    return "player"
  end
  if TELEPORTATION_WITH_COORDINATES then
    local x_pos, y_pos, z_pos = string.match(param, "(%S+) (%S+) (%S+)")
    if x_pos ~=nil and y_pos ~= nil and z_pos ~= nil then
      x_pos = tonumber(x_pos)
      y_pos = tonumber(y_pos)
      z_pos = tonumber(z_pos)
      if x_pos ~=nil and y_pos ~= nil and z_pos ~= nil then
        return {x = x_pos, y = y_pos, z = z_pos}
      end
    end
  end

  return nil
end

function jeans_teleportation_teleport(name, dest_pos)
  local player_pos = minetest.get_player_by_name(name):get_pos()
  local price = math.floor(vector.distance(player_pos, dest_pos) / 100 * PRICE_PER_100_BLOCKS)
  -- Double Price For Miners:
  if HIGHER_PRICE_FOR_MINERS and (player_pos["y"] < MINER_DEFINITION or dest_pos["y"] < MINER_DEFINITION) then
    local deepness
    if player_pos["y"] < MINER_DEFINITION then
      deepness = player_pos["y"]
    else
      deepness = dest_pos["y"]
    end
    price = math.floor(price * (MINER_FACTOR ^ math.floor(deepness / -1000)))
  end

  if jeans_economy and jeans_economy_book(name, "!SERVER!", price , "Teleported "..name.." to x:"..dest_pos["x"].." y:"..dest_pos["y"].." z:"..dest_pos["z"]) then
    minetest.chat_send_player(name, "The teleportation has costed you "..price..".")
    minetest.get_player_by_name(name):set_pos(dest_pos)
  elseif not jeans_economy then
    minetest.chat_send_player(name, "Teleporting...")
    minetest.get_player_by_name(name):set_pos(dest_pos)
  else
    minetest.chat_send_player(name, "Apparently you don't have enough money. It costs you "..price..".")
  end

end
