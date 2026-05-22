local spawn_time = 40
local timer = 0

function on_block_tick(x, y, z, tps)
    timer = timer + 1 / tps
    if timer >= spawn_time then
        entities.spawn("newgen:weaver", {x + random.random(-2, 2), y, z + random.random(-2, 2)})
        timer = 0
    end
end