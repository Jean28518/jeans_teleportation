--------------------------------------------------------------------------------
-- COMMANDS --------------------------------------------------------------------
--------------------------------------------------------------------------------

minetest.register_chatcommand("tp", {
  privs = {
    interact = true,
  },
  func = function(name, param)
    local dest_pos = jeans_teleportation.analyze_command(name, param)
    if dest_pos == nil then
      minetest.chat_send_player(name, "Homepoint/Player/Coordinate not known. Type /tp_help to see how this command is used")
    elseif dest_pos == "player" then
      minetest.chat_send_player(name, "Request sended. You can cancel your request with /tp_canc")
    else
      jeans_teleportation.teleport(name, dest_pos)
    end

  end
})

if jeans_teleportation.ACTIVATE_HOMEPOINTS then
  minetest.register_chatcommand("tp_add", {
    privs = {
      interact = true,
    },
    func = function(name, param)
      local homes = minetest.deserialize(jeans_teleportation.storage:get_string("homes"))
      if param == "" then
        minetest.chat_send_player(name, "You have to define a specific name!")
        return
      end
      if homes[name] == nil then
        homes[name] = {}
      end
      homes[name][param] = minetest.get_player_by_name(name):get_pos()
      jeans_teleportation.storage:set_string("homes", minetest.serialize(homes))
      minetest.chat_send_player(name, "Home successfully added!")
    end
  })
end

minetest.register_chatcommand("tp_del", {
  privs = {
    interact = true,
  },
  func = function(name, param)
    local homes = minetest.deserialize(jeans_teleportation.storage:get_string("homes"))
    if homes[name] == nil then
      homes[name] = {}
    end
    homes[name][param] = nil
    minetest.chat_send_player(name, "Home successfully deleted!")
    jeans_teleportation.storage:set_string("homes", minetest.serialize(homes))
  end
})
minetest.register_chatcommand("tp_list", {
  privs = {
    interact = true,
  },
  func = function(name, param)
    local homes = minetest.deserialize(jeans_teleportation.storage:get_string("homes"))
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
      jeans_teleportation.teleport(tp_requests[name], minetest.get_player_by_name(name):get_pos())
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

minetest.register_chatcommand("tp_confirm", {
    params = "",
    description = "Confirms teleportation with a high price",
    privs = {interact=true},
    func = function(player_name, param)
      jeans_teleportation.confirm_high_price(player_name)
    end
})

minetest.register_chatcommand("tp_help", {
  privs = {
    interact = true,
  },
  func = function(name, param)
    minetest.chat_send_player(name, "## How to use Jean's teleportation: ##")
    if jeans_teleportation.SPAWN_POS then
      minetest.chat_send_player(name, "/tp spawn: Teleports you to spawn")
    end
    if jeans_teleportation.ACTIVATE_PLAYER_TP then
      minetest.chat_send_player(name, "/tp <player>: Sends a teleporting request to another player")
    end
    if jeans_teleportation.TELEPORTATION_WITH_COORDINATES then
      minetest.chat_send_player(name, "/tp <x> <y> <z>: Teleports you to a specific location")
    end
    if jeans_teleportation.ACTIVATE_HOMEPOINTS then
      minetest.chat_send_player(name, "/tp_add <home_name>: Adds a homepoint on your current postion. You can define unlimited home points")
      minetest.chat_send_player(name, "/tp <home_name>: Teleports you to a homepoint")
      minetest.chat_send_player(name, "/tp_list: Shows all your saved homepoints")
      minetest.chat_send_player(name, "/tp_del <home_name>: Deletes a specific home point")
    end
    if jeans_teleportation.ACTIVATE_TELEPORT_TO_LAST_DEATH then
      minetest.chat_send_player(name, "/tp death: Teleports you to your last death point")
    end
    if jeans_economy and jeans_teleportation.PRICE_PER_100_BLOCKS ~= 0 then
      minetest.chat_send_player(name, "ATTENTION: Teleporting costs you money! Per 100 Blocks: "..jeans_teleportation.PRICE_PER_100_BLOCKS)
      if HIGHER_PRICE_FOR_MINERS then
        minetest.chat_send_player(name, "For miners which are teleporting under y ="..jeans_teleportation.MINER_DEFINITION.." the price of telportation grows with deepness.")
      end
    end
    minetest.chat_send_player(name, "Press F10 to see the whole message.")
  end
})
