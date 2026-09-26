local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Module = api.utils.classes.module
local Message = api.messages

local stats = m.side == "server" and require "server/stats" or nil

local RespawnMessage = Message.new("newgen", "respawn", {})

local self = Module()

-- SERVER

function self.server.respawn(client)
    local pid = client.player.pid
    local replica = stats.get(pid)

    if not replica or not replica.is_dead then return end

    local sx, sy, sz = player.get_spawnpoint(pid)
    player.set_pos(pid, sx, sy, sz)

    local pentity = entities.get(player.get_entity(pid))
    if not pentity then return end

    local stats_component = pentity:get_component("newgen:stats")

    stats_component.set_stat("is_dead", false)
    stats_component.set_stat("oxygen", replica.max_oxygen)
    stats_component.set_stat("hunger", 0)
    stats_component.set_stat("hp", replica.max_hp)
end

RespawnMessage:on(function(client)
    self.respawn(client)
end)

-- CLIENT

function self.client.on_respawn()
    RespawnMessage:send({})
end

return self:build()