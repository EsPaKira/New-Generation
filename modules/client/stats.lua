local StatsReplication = require "stats_replication"

local stats
local module = {}


function module.get_stat(stat)
    return stats[stat]
end

events.on("newgen:player_loaded", function(pid)
    stats = StatsReplication:create_listener(pid, {})
end)

return module