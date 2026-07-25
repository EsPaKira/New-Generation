local MAX_CROP_V = 2
local DI = require "drop_inventory"

function on_use_on_block(x, y, z, pid)
    if block.properties[block.get(x, y, z)]["script-name"] ~= "crop" then return end

    local block_v = block.get_variant(x, y, z)

    if block_v < MAX_CROP_V then
        block.set_variant(x, y, z, block_v + 1)
    else
        DI.drop_inventory(0, {x, y, z}, nil, pid)
        block.set_variant(x, y, z, 0)
        return true
    end

    if player.is_infinite_items(pid) then
        return true
    end

    local pinvid, slot = player.get_inventory(pid)
    inventory.decrement(pinvid, slot, 1)
    return true
end