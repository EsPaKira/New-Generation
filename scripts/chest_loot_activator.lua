function on_use_on_block(x, y, z)
    if block.properties[block.get(x, y, z)]["newgen:have-loot"] then
        block.set_variant(x, y, z, 0)
        gfx.particles.emit({x + 0.5, y + 1.2, z + 0.5}, 10, {
            lifetime = 1.5,
            lifetime_spread = 0.3,
            spawn_interval = 0.0001,
            explosion = {0.5, 0.1, 0.5},
            angle_spread = 0.05,
            velocity = {0, -0.3, 0},
            acceleration = {0, -0.1, 0},
            size = {0.3, 0.3, 0.3},
            spawn_shape = "box",
            spawn_spread = {0.5, 0.1, 0.5},
            lighting = false,
            collision = true,
            frames = {
                "particles:chest_activate"
            }
        })
    end
    return true
end