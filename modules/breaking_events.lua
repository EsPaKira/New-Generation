local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Module = api.utils.classes.module
local PredictedEvent = api.predicted_events

local self = Module()


function self.server.on_start(client, data)
    local pid = client.player.pid
    local px, py, pz = player.get_pos(pid)
    local x, y, z = unpack(data.pos)
    local reach_distance = player.get_interaction_distance(pid)

    if vec3.distance({px, py, pz}, {x, y, z}) > reach_distance then
        return false
    end
    return true
end

function self.server.on_interrupt(client, instant) end

function self.server.on_tick(client, instant)
    return instant:get_progress() + 0.05
end

function self.server.on_finish(client, instant)
    local x, y, z = unpack(instant.data.pos)
    block.destruct(x, y, z, client.player.pid)
end


function self.client.on_ack_start(instant) end
function self.client.on_reject(instant) end
function self.client.on_progress(instant) end
function self.client.on_finish(instant) end
function self.client.on_interrupt(instant) end


local BreakingEvent = PredictedEvent.new("newgen", "breaking", { pos = "Triple<int32, uint8, int32>" }, self:build())

return BreakingEvent