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

    if vec3.distance({px, py, pz}, {x, y, z}) > 5.35 then -- 5.35 only for base player model 
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

local function breaking_particles(x, y, z)
    local blockid = block.get(x, y, z)
    gfx.particles.emit({x + 0.5, y + 0.5, z + 0.5}, 4, {
        lifetime = 1.0,
        spawn_interval = 0.0001,
        explosion = {3, 3, 3},
        velocity = {0, 0.5, 0},
        texture = "blocks:" .. block.get_textures(blockid)[1],
        random_sub_uv = 0.1,
        size = {0.1, 0.1, 0.1},
        size_spread = 0.2,
        spawn_shape = "box",
        collision = false
    })
end

local function breaking_sounds(x, y, z)
    local blockid = block.get(x, y, z)
    local material = block.materials[block.material(blockid)]
    audio.play_sound(
        1 >= 1.2 and -- tenporary solution
            material.hitSound or
            material.stepsSound, 
        x + 0.5, y + 0.5, z + 0.5,
        1.0, 0.9 + math.random() * 0.2, "regular"
    )
end

local function breaked_sound(instant)
    local x, y, z = unpack(instant.data.pos)
    local material = block.materials[block.material(instant.data.blockid)]
    audio.play_sound(
        material.breakSound,
        x + 0.5, y + 0.5, z + 0.5,
        1.0, 0.9 + math.random() * 0.2, "regular"
    )
end

function self.client.on_ack_start(instant)
    if instant.abandoned then
        instant:interrupt()
        return
    end

    instant.data.wrapper = gfx.blockwraps.wrap(instant.data.pos, wrap_texture(0))
    instant.data.blockid = block.get(unpack(instant.data.pos))
end

function self.client.on_reject(instant) end

function self.client.on_progress(instant)
    if not instant.data.wrapper then return end

    instant.data.tick = (instant.data.tick or 0) + 1

    if instant.data.tick % 4 == 0 then
        local x, y, z = unpack(instant.data.pos)
        breaking_particles(x, y, z)
        breaking_sounds(x, y, z)
    end

    gfx.blockwraps.set_texture(instant.data.wrapper, wrap_texture(instant:get_progress()))
end

function self.client.on_finish(instant)
    delete_wrap(instant)
    breaked_sound(instant)
end

function self.client.on_interrupt(instant)
    delete_wrap(instant)
end


local BreakingEvent = PredictedEvent.new("newgen", "breaking", { pos = "Triple<int32, uint8, int32>" }, self:build())

return BreakingEvent