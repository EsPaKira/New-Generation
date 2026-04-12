function on_interact(x, y, z, pid)
    local pinvid, slot = player.get_inventory(pid)
    local itemid, count = inventory.get(pinvid, slot)
    
    if item.name(itemid) == "base:torch.item" then
        local finvid = inventory.get_block(x, y, z)
        local fitemid, fcount = inventory.get(finvid, 1)
        local furnaces = require "furnaces"
        if furnaces.check(finvid, 1, "fuel") then
            block.set_variant(x, y, z, 1)
            print("add", finvid)
            furnaces.add(x, y, z, finvid, 300)
            return true
        end
    end
    hud.open_block(x, y, z)
    hud.open_permanent("newgen:player_button")

    return true
end

events.on("newgen:furnace.update", function(t, m, pos)
    if random.random(1, 10) > 7 then 
        pos[2] = pos[2] + 1
        pos[1] = pos[1] + 0.5
        pos[3] = pos[3] + 0.5
        gfx.particles.emit(pos, 4, {
            lifetime = 9,
            lifetime_spread = 1,
            spawn_interval = 0.0001,
            explosion = {0.2, 2, 0.2},
            angle_spread = 0.05,
            velocity = {0, 0.3, 0},
            acceleration = {0, -0.1, 0},
            size = {0.4, 0.4, 0.4},
            spawn_shape = "box",
            spawn_spread = {0.1, 0.1, 0.1},
            lighting = false,
            collision = true,
            frames = {
                "particles:smoke_0",
                "particles:smoke_1"
            }
        })
    end
end)