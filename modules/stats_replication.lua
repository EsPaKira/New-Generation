local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local config = require "config"

local schema = {}

for stat, data in pairs(config.stats) do
    schema[stat] = data.net_type
end

schema.choosen_character = "string"


local StatsReplication = api.replications.new(PACK_ID, "stats", schema)

return StatsReplication