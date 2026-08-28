local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local StatsReplication = require "stats_replication"
local metadata = require "server/metadata"
local module = {}


local function get_character_stats(character_id)
    local character_data = file.read_combined_object("characters/" .. character_id .. ".json")
    return character_data.stats
end

local function set_stats(pid, character_id)
    local pentity = entities.get(player.get_entity(pid))
    local stats_component = pentity:get_component("newgen:stats")

    local identity = api.sandbox.players.get_by_pid(pid).identity
    local replica = module.get(pid)

    if not metadata.data.players[identity] then
        metadata.data.players[identity] = {
            characters = {}
        }
        metadata.data.players[identity].characters[character_id] = {
            stats = {}
        }

        local character_stats = get_character_stats(character_id)

        for stat, value in pairs(character_stats) do
            replica[stat] = value
            metadata.data.players[identity].characters[character_id].stats[stat] = value
            stats_component.set_stat(stat, value, true)
        end
    else
        for stat, value in pairs(metadata.data.players[identity].characters[character_id].stats) do
            replica[stat] = value
            stats_component.set_stat(stat, value, true)
        end
    end

    replica.choosen_character = character_id
    metadata.data.players[identity].choosen_character = character_id
end

function module.add(uid, initial, client)
    return StatsReplication:create_private_replica(uid, initial, client)
end

function module.get(uid)
    return StatsReplication:get_replica(uid)
end


events.on("server:on_player_ready", function(client)
    module.add(client.player.pid, {}, client)
    set_stats(client.player.pid, "player")
end)

return module