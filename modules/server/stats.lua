local StatsReplication = require "stats_replication"
local module = {}


local function set_stats(pid)
    local pentity = entities.get(player.get_entity(pid))
    local stats_component = pentity:get_component("newgen:stats")
    local stats = stats_component.get_all_stats()

    local replica = module.get(pid)
    for stat, value in pairs(stats) do
        replica[stat] = value
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