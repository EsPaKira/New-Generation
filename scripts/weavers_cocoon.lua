local spawn_time = 20
local timer = 0
local entity_limit = 4
local spawners = require "spawners"

function on_block_present(x, y, z)
    if block.is_segment(x, y, z) then return end -- use only in extended blocks

    spawners.add_spawner(x, y, z, 4, 20)
end

function on_broken(x, y, z)
    if block.is_segment(x, y, z) then return end

    spawners.remove_spawner(x, y, z)
end