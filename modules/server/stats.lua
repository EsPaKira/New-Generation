local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local StatsReplication = require "stats_replication"
local metadata = require "server/metadata"
local module = {}


local function set_stats(pid)
    local pentity = entities.get(player.get_entity(pid))
    local stats_component = pentity:get_component("newgen:stats")

    local replica = module.get(pid)

    if not metadata.data.players[api.sandbox.players.get_by_pid(pid).identity] then
        metadata.data.players[api.sandbox.players.get_by_pid(pid).identity] = {}
        local stats = stats_component.get_all_stats()

        for stat, value in pairs(stats) do
            replica[stat] = value
            metadata.data.players[api.sandbox.players.get_by_pid(pid).identity][stat] = value
        end
    else
        for stat, value in pairs(metadata.data.players[api.sandbox.players.get_by_pid(pid).identity]) do

            replica[stat] = value
            stats_component.set_stat(stat, value)
        end
    end
end

function module.add(uid, initial, client)
    return StatsReplication:create_private_replica(uid, initial, client)
end

function module.get(uid)
    return StatsReplication:get_replica(uid)
end


events.on("server:on_player_ready", function(client)
    module.add(client.player.pid, {}, client)
    set_stats(client.player.pid)
end)

return module