local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2])).server
local Message = import "net/protocol/message"

local gamemodes = {}


local GamemodeMsg = Message.new("newgen", "gamemode.set", {
    name = "boolean"
})

function gamemodes.set(client, gamemode)
    local player_obj = client.player

    if gamemode == "survival" then
        api.rules.players.set_value(player_obj, "allow-content-access", false)
        api.rules.players.set_value(player_obj, "allow-flight", false)
        api.rules.players.set_value(player_obj, "allow-noclip", false)
        api.rules.players.set_value(player_obj, "allow-cheat-movement", false)
        api.rules.players.set_value(player_obj, "allow-debug-cheats", false)
        api.rules.players.set_value(player_obj, "allow-fast-interaction", false)
        api.rules.players.set_value(player_obj, "infinite-items", false)

        player.set_interaction_distance(player_obj.pid, 5)
    else -- gamemode == "creative"
        api.rules.players.set_value(player_obj, "allow-content-access", true)
        api.rules.players.set_value(player_obj, "allow-flight", true)
        api.rules.players.set_value(player_obj, "allow-noclip", true)
        api.rules.players.set_value(player_obj, "allow-cheat-movement", true)
        api.rules.players.set_value(player_obj, "allow-debug-cheats", true)
        api.rules.players.set_value(player_obj, "allow-fast-interaction", true)
        api.rules.players.set_value(player_obj, "infinite-items", true)

        player.set_interaction_distance(player_obj.pid, 10)
    end

    GamemodeMsg:tell(client, { name = (gamemode == "creative") })
end

function gamemodes.is_exists(gamemode)
    return gamemode == "survival" or gamemode == "creative"
end

return gamemodes