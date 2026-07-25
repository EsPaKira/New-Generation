local spawn = require "spawn"
local mob_name = "newgen:skeleton"
local variants = {
    {name = "skeleton", weight = 0.5},
    {name = "mossy_skeleton", weight = 0.5},
    {name = "vestured_skeleton", weight = 0.5},
}
local dirt_id = block.index("base:dirt")
local grass_block_id = block.index("base:grass_block")
local water_id = block.index("base:water")
local farmland_id = block.index("newgen:farmland")

function on_random_update(x, y, z)
    if block.is_solid_at(x, y + 1, z) or block.get(x, y + 1, z) == farmland_id then
        block.set(x, y, z, dirt_id, 0)
    else
        for lx = -1, 1 do
            for ly = -1, 1 do
                for lz = -1, 1 do
                    if block.get(x + lx, y + ly, z + lz) == dirt_id then
                        local top_block = block.get(x + lx, y + ly + 1, z + lz)
                        if not block.is_solid_at(x + lx, y + ly + 1, z + lz) and top_block ~= water_id and top_block ~= farmland_id then
                            block.set(x + lx, y + ly, z + lz, grass_block_id, 0)
                            return
                        end
                    end
                end
            end
        end
        spawn.try_spawn_at(x, y, z, mob_name, 4, variants)
    end
end