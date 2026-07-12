local spawn = require "spawn"
local mob_name = "newgen:skeleton"
local variants = {
    {name = "skeleton", weight = 0.5},
    {name = "mossy_skeleton", weight = 0.5},
    {name = "vestured_skeleton", weight = 0.5},
}

function on_random_update(x, y, z)
    local dirtid = block.index('base:dirt')
    if block.is_solid_at(x, y + 1, z) then
        block.set(x, y, z, dirtid, 0)
    else
        for lx = -1, 1 do
            for ly = -1, 1 do
                for lz = -1, 1 do
                    if block.get(x + lx, y + ly, z + lz) == dirtid then
                        if not block.is_solid_at(x + lx, y + ly + 1, z + lz) and block.get(x + lx, y + ly + 1, z + lz) ~= block.index("base:water") then
                            block.set(x + lx, y + ly, z + lz, block.index('base:grass_block'), 0)
                            return
                        end
                    end
                end
            end
        end
        spawn.try_spawn_at(x, y, z, mob_name, 4, variants)
    end
end