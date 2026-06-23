local function particles(x, y, z)
    local block_frames = block.properties[block.get(x, y, z)]["newgen:placed_particles"]

    if not block_frames then return end

    gfx.particles.emit({x + 0.5, y + 0.5, z + 0.5}, 15, {
        lifetime = 1.5,
        lifetime_spread = 0.3,
        spawn_interval = 0.0001,
        explosion = {1, 0.5, 1},
        angle_spread = 0.05,
        velocity = {0, -0.3, 0},
        acceleration = {0, -0.1, 0},
        size = {0.25, 0.25, 0.25},
        spawn_shape = "box",
        spawn_spread = {0.6, 0.6, 0.6},
        lighting = true,
        collision = false,
        frames = block_frames
    })
end

local function update(x, y, z)
    if block.is_replaceable_at(x, y-1, z) then
        block_name = block.name(block.get(x, y, z))
        entities.spawn("base:falling_block", {x+0.5, y+0.5, z+0.5}, 
            {base__falling_block={block=block_name}})
        particles(x, y, z)
        block.set(x, y, z, 0)
    end
end

function on_update(x, y, z)
    update(x, y, z)
end

function on_placed(x, y, z)
    update(x, y, z)

    particles(x, y, z)
end