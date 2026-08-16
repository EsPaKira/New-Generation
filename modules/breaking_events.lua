local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Module = api.utils.classes.module
local PredictedEvent = api.predicted_events

local self = Module()

-- SERVER

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

-- CLIENT

local function wrap_texture(progress)
    return "cracks/cracks_" .. math.floor(progress * 11)
end

local function delete_wrap(instant)
    if instant.data.wrapper then
        gfx.blockwraps.unwrap(instant.data.wrapper)
        instant.data.wrapper = nil
    end
end

function self.client.on_ack_start(instant)
    local x, y, z = unpack(instant.data.pos)
    instant.data.wrapper = gfx.blockwraps.wrap({x, y, z}, wrap_texture(0))
end

function self.client.on_reject(instant) end
function self.client.on_progress(instant)
    if not instant.data.wrapper then return end

    gfx.blockwraps.set_texture(instant.data.wrapper, wrap_texture(instant:get_progress()))
end

function self.client.on_finish(instant)
    delete_wrap(instant)
end

function self.client.on_interrupt(instant)
    delete_wrap(instant)
end


local BreakingEvent = PredictedEvent.new("newgen", "breaking", { pos = "Triple<int32, uint8, int32>" }, self:build())

return BreakingEvent