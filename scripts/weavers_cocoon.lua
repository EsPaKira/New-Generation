local spawn_time = 20
local timer = 0
local entity_limit = 4
local spawners = require "spawners"

function on_block_present(x, y, z)
    if block.is_segment(x, y, z) then return end -- use only in extended blocks

    spawners.add_spawner(x, y, z)
end

function on_broken(x, y, z)
    if block.is_segment(x, y, z) then return end

    spawners.remove_spawner(x, y, z)
end

function on_block_tick(x, y, z, tps)
    if block.is_segment(x, y, z) then return end

    timer = timer + 1 / tps
    if timer >= spawn_time then
        local spawner = spawners.get_spawner(x, y, z)
        if #spawner[4] < entity_limit then 
            local entity = entities.spawn("newgen:weaver", {x + random.random(-1, 1), y, z + random.random(-1, 1)})
            spawners.add_entity(x, y, z, entity:get_uid())
            timer = 0
        end
    end
end