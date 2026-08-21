local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Module = api.utils.classes.module
local PredictedEvent = api.predicted_events

local base_util = require "base:util"
local block_drop = require "server/block_drop"

local self = Module()

-- SERVER

local function get_durability(blockid)
    local durability = block.properties[blockid]["base:durability"]
    if durability ~= nil then
        return math.max(durability, 1e-5)
    end
    if block.get_model(blockid) == "X" then
        return 1e-5
    end
    return 1.0
end

function self.server.on_start(client, data)
    local pid = client.player.pid
    local px, py, pz = player.get_pos(pid)
    local pentity = entities.get(player.get_entity(pid))
    local hitbox_height = pentity.rigidbody:get_size()[2]
    local camera_offset = client.player.is_crouching and 0.5 or 0.7 -- 0.5 if crouching. 0.7 if standing
    local hitbox_offset = hitbox_height * (camera_offset / 1.8)

    local raycast = block.raycast({px, py + hitbox_offset, pz}, player.get_dir(pid), player.get_interaction_distance(pid))

    if not raycast then
        return false
    end

    return true
end

function self.server.on_interrupt(client, instant) end

function self.server.on_tick(client, instant)
    local x, y, z = unpack(instant.data.pos)

    if player.is_instant_destruction(client.player.pid) then
        block_drop.drop_block(x, y, z, client.player.pid)
        return 1
    end

    local blockid = block.get(x, y, z)
    local speed = 1.0 / get_durability(blockid)
    local power = 1.0

    local invid, slot = player.get_inventory(client.player.pid)
    local itemid, _ = inventory.get(invid, slot)
    local tool = item.properties[itemid]["newgen:tool"]
    if tool and tool.type == "breaker" then
        for material, material_speed in pairs(tool.materials) do
            if block.has_tag(blockid, material) then
                power = material_speed
                break
            end
        end
    end
    speed = speed * power

    return instant:get_progress() + 0.05 * speed
end

function self.server.on_finish(client, instant)
    local x, y, z = unpack(instant.data.pos)

    block_drop.drop_block(x, y, z, client.player.pid)

    block.destruct(x, y, z, client.player.pid)

    -- ITEM USES

    local pinvid, slot = player.get_inventory(client.player.pid)
    local itemid = inventory.get(pinvid, slot)

    if item.properties[itemid]["newgen:tool"] and item.properties[itemid]["newgen:tool"].type == "breaker" then
        inventory.use(pinvid, slot)
    end
end

-- CLIENT

local function wrap_texture(progress)
    return "cracks/cracks_" .. math.floor(progress * 10)
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
        random.random(0, 1) == 0 and
            material.hitSound or
            material.stepsSound, 
        x + 0.5, y + 0.5, z + 0.5,
        1.0, 0.9 + math.random() * 0.2, "regular"
    )
end

local function breaked_sound(instant)
    local pid = hud.get_player()
    if player.is_instant_destruction(pid) then return end

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
    breaking_sounds(unpack(instant.data.pos))
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


local BreakingEvent = PredictedEvent.new("newgen", "breaking", { pos = "Triple<int32, uint8, int32>", blockid = "uint16" }, self:build())

return BreakingEvent