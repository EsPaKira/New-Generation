local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local config = require "config"

local schema = {}

for stat, data in pairs(config.stats) do
    schema[stat] = data.net_type
end


local StatsReplication = api.replications.new("newgen", "stats", schema)

return StatsReplication