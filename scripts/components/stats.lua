local m = _G["$Multiplayer"]
if m.side == "client" then return end

local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local server_stats = require "server/stats" 
local metadata = require "server/metadata"
local config = require "config"

local stats = {}


local function def_stats(name, def_value)
    stats[name] = SAVED_DATA[name] or ARGS[name] or def_value
    this["get_" .. name] = function()
        return stats[name] or SAVED_DATA[name] or ARGS[name] or def_value
    end
end

for stat, data in pairs(config.stats) do
    def_stats(stat, data.default)
end

function set_stat(stat, value, from_stats_module)
    stats[stat] = value
    SAVED_DATA[stat] = value

    if m.side == "server" then
        if from_stats_module then return end

        local pid = entity:get_player()
        if pid ~= -1 and pid ~= 0 then
            local replica = server_stats.get(pid)
            if replica then
                replica[stat] = value
            end

            local identity = api.sandbox.players.get_by_pid(pid).identity

            local record = metadata.data.players[identity]
            if not record or not record.choosen_character then
                return -- called before server:on_player_ready in server/stats.lua
            end

            local character_id = record.choosen_character
            local character = record.characters[character_id]
            if not character then
                character = { stats = {} }
                record.characters[character_id] = character
            end

            character.stats[stat] = value
        end
    end  
end

function get_all_stats()
    return stats
end