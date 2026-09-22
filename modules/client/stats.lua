local StatsReplication = require "stats_replication"

local stats
local module = {}


function module.get_stat(stat)
    return stats[stat]
end

function module.get_all()
    return stats
end

stats = StatsReplication:create_listener(hud.get_player(), {})

return module