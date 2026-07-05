local MAX_CROP_V = 2
local DI = require "drop_inventory"

function on_random_update(x, y, z)
    farmland_v = block.get_variant(x, y - 1, z)
    if farmland_v == 0 then return end

    crop_v = block.get_variant(x, y, z) + 1
    if crop_v <= MAX_CROP_V then
        block.set_variant(x, y, z, crop_v)
    end
end

function on_interact(x, y, z, pid)
    if block.get_variant(x, y, z) == MAX_CROP_V then
        DI.drop_inventory(0, {x, y, z}, nil, pid)
        block.set_variant(x, y, z, 0)
    end
end