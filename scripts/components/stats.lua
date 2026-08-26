local m = _G["$Multiplayer"]

local stats = {}

local function def_stats(name, def_value)
    stats[name] = SAVED_DATA[name] or ARGS[name] or def_value
    this["get_" .. name] = function()
        return stats[name] or SAVED_DATA[name] or ARGS[name] or def_value
    end
end

if m.side == "server" then
    local config = require "config"
    for stat, data in pairs(config.stats) do
        def_stats(stat, data.default)
    end
end

function set_stat(stat, value)
    stats[stat] = value
    SAVED_DATA[stat] = value
end

function get_all_stats()
    return stats
end