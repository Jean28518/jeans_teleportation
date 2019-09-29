local pending_teleportations_high_prices = { }

local jeans_economy = false
if minetest.get_modpath("jeans_economy") then jeans_economy = true end

function jeans_teleportation.analyze_command(playername, param)
  if param == "spawn" then
    return jeans_teleportation.SPAWN_POS
  end
  -- YOU CAN COMMENT OUT THIS SECTION AND DEFINE YOUR OWN GLOBAL TP POINTS.
  -- (OF COURSE YOU CAN duplicate this three lines of code how many times you want)
  -- if param == "YOUR TP NAME" then
  --   return {x = 0, y = 0, z = 0}
  -- end

  local homes = minetest.deserialize(jeans_teleportation.storage:get_string("homes"))
  if homes[playername] ~= nil then
    for home_name, home_pos in pairs(homes[playername]) do
      if param == home_name then
        return home_pos
      end
    end
  end
  if jeans_teleportation.ACTIVATE_PLAYER_TP then
    if minetest.get_player_by_name(param) then
      tp_requests[param] = playername -- minetest.get_player_by_name(param):get_pos()
      minetest.chat_send_player(param, playername.." wants to teleport itself to you. Accept with /tp_yes")
      return "player"
    end
  end
  if jeans_teleportation.TELEPORTATION_WITH_COORDINATES then
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

function jeans_teleportation.teleport(player_name, destination)
  local player_pos = minetest.get_player_by_name(player_name):get_pos()
  local price = math.floor(vector.distance(player_pos, destination) / 100 * jeans_teleportation.PRICE_PER_100_BLOCKS)
  -- Double Price For Miners:
  if jeans_teleportation.HIGHER_PRICE_FOR_MINERS and (player_pos["y"] < jeans_teleportation.MINER_DEFINITION or destination["y"] < jeans_teleportation.MINER_DEFINITION) then
    local deepness
    if player_pos["y"] < jeans_teleportation.MINER_DEFINITION then
      deepness = player_pos["y"]
    else
      deepness = destination["y"]
    end
    price = math.floor(price * (jeans_teleportation.MINER_FACTOR ^ math.floor(deepness / -1000)))
  end

  -- If The price is above the Hurdle, then the mod waits for the confirmation from the player with /tp_confirm
  if jeans_economy and price > jeans_teleportation.PRICEHURDLE then
    minetest.chat_send_player(player_name, "This teleportation costs "..price..". If you want to teleport, type /tp_confirm")
    pending_teleportations_high_prices[player_name] = { }
    pending_teleportations_high_prices[player_name].destination = destination
    pending_teleportations_high_prices[player_name].price = price
    minetest.after(60, function() jeans_teleportation.delete_request(player_name) end)
  else   -- Else it teleports instantly:
    jeans_teleportation.handle_teleport(player_name, destination, price)
  end
end

function jeans_teleportation.handle_teleport(player_name, destination, price)
  if jeans_economy and jeans_economy_book(player_name, "!SERVER!", price , "Teleported "..player_name.." to x:"..destination["x"].." y:"..destination["y"].." z:"..destination["z"]) then
    minetest.chat_send_player(player_name, "The teleportation has costed you "..price..".")
    minetest.get_player_by_name(player_name):set_pos(destination)
  elseif not jeans_economy then
    minetest.chat_send_player(player_name, "Teleporting...")
    minetest.log("action", "Teleporting "..player_name.." to x:"..destination["x"].." y:"..destination["y"].." z:"..destination["z"])
    minetest.get_player_by_name(player_name):set_pos(destination)
  else
    minetest.chat_send_player(player_name, "Apparently you don't have enough money. It costs you "..price..".")
  end
end

-------------------------------------------------------------------------------
-- These are helper functions for confirming higher prices.
-------------------------------------------------------------------------------

function jeans_teleportation.delete_request(player_name)
  pending_teleportations_high_prices[player_name] = nil
end

function jeans_teleportation.confirm_high_price(player_name)
  if pending_teleportations_high_prices[player_name] ~= nil then
    jeans_teleportation.handle_teleport(player_name, pending_teleportations_high_prices[player_name].destination, pending_teleportations_high_prices[player_name].price)
    pending_teleportations_high_prices[player_name] = nil
  else
    minetest.chat_send_player(player_name, "No pending teleporting requests.")
  end
end
