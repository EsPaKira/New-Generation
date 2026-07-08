local spawn = require "spawn"
local mob_name = "newgen:skeleton"
local variants = {
    {name = "skeleton", weight = 0.5},
    {name = "mossy_skeleton", weight = 0.5},
    {name = "vestured_skeleton", weight = 0.5},
}

function on_use_on_block(x, y, z)
    spawn.spawn(x + 0.5, y + 1, z + 0.5, mob_name, 1000, variants)
end