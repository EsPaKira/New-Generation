local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Module = api.utils.classes.module
local Message = api.messages

local stats = m.side == "server" and require "server/stats" or nil

local RespawnMessage = Message.new("newgen", "respawn", {}) -- client > server. Requires player respawn
local RespawnedMessage = Message.new("newgen", "respawned", { uid = "int16" }) -- server > client
local DeathMessage = Message.new("newgen", "death", { uid = "int16" }) -- server > client

local function get_entity_by_neutron_uid(uid)
    local cuid = api.entities.server_to_client_uid(uid)
    if not cuid then return nil end

    return entities.get(cuid)
end


local self = Module()

-- SERVER

function self.server.respawn(client)
    local pid = client.player.pid
    local replica = stats.get(pid)

    if not replica or not replica.is_dead then return end

    local sx, sy, sz = player.get_spawnpoint(pid)
    player.set_pos(pid, sx, sy, sz)

    local uid = player.get_entity(pid)
    local pentity = entities.get(uid)
    if not pentity then return end

    local stats_component = pentity:get_component("newgen:stats")

    stats_component.set_stat("is_dead", false)
    stats_component.set_stat("oxygen", replica.max_oxygen)
    stats_component.set_stat("hunger", 0)
    stats_component.set_stat("hp", replica.max_hp)

    RespawnedMessage:echo({ uid = uid })
end

function self.server.notify_death(uid)
    DeathMessage:echo({ uid = uid })
end

RespawnMessage:on(function(client)
    self.respawn(client)
end)

-- CLIENT

function self.client.on_respawn()
    RespawnMessage:send({})
end

DeathMessage:on(function(data)
    local pentity = get_entity_by_neutron_uid(data.uid)
    if not pentity then return end

    pentity.skeleton:set_visible(false)
end)

RespawnedMessage:on(function(data)
    local pentity = get_entity_by_neutron_uid(data.uid)
    if not pentity then return end

    pentity.skeleton:set_visible(true)
end)

return self:build()