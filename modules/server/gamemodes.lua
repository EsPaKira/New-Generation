local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]

local gamemodes = {
    players = {}
}


function gamemodes.set(client, gamemode)
    local player_obj = client.player

    local player_gamemode = gamemodes.get(player_obj.identity, player_obj.pid)

    local allow_content_access = api.rules.get_rule("allow-content-access")
    local allow_flight = api.rules.get_rule("allow-flight")
    local allow_noclip = api.rules.get_rule("allow-noclip")
    local allow_cheat_movement = api.rules.get_rule("allow-cheat-movement")
    local allow_debug_cheats = api.rules.get_rule("allow-debug-cheats")
    local allow_fast_interaction = api.rules.get_rule("allow-fast-interaction")

    if gamemode == "survival" then
        api.rules.players.set_value(player_obj, allow_content_access, false)
        api.rules.players.set_value(player_obj, allow_flight, false)
        api.rules.players.set_value(player_obj, allow_noclip, false)
        api.rules.players.set_value(player_obj, allow_cheat_movement, false)
        api.rules.players.set_value(player_obj, allow_debug_cheats, false)
        api.rules.players.set_value(player_obj, allow_fast_interaction, false)

        player.set_infinite_items(player_obj.pid, false)
        player.set_instant_destruction(player_obj.pid, false)
        player.set_interaction_distance(player_obj.pid, 5)
    else -- gamemode == "creative"
        api.rules.players.set_value(player_obj, allow_content_access, true)
        api.rules.players.set_value(player_obj, allow_flight, true)
        api.rules.players.set_value(player_obj, allow_noclip, true)
        api.rules.players.set_value(player_obj, allow_cheat_movement, true)
        api.rules.players.set_value(player_obj, allow_debug_cheats, true)
        api.rules.players.set_value(player_obj, allow_fast_interaction, true)

        player.set_infinite_items(player_obj.pid, true)
        player.set_instant_destruction(player_obj.pid, true)
        player.set_interaction_distance(player_obj.pid, 10)
    end

    player_gamemode.current = gamemode
end

function gamemodes.get(identity, pid)
    if gamemodes.players[identity] == nil then
        gamemodes.players[identity] = {
            current=player.is_infinite_items(pid)
            and "creative" or "survival"}
    end
    return gamemodes.players[identity]
end

function gamemodes.is_exists(gamemode)
    return gamemode == "survival" or gamemode == "creative"
end

return gamemodes