local farmlandid = block.index("newgen:farmland")

local function watering(x, y, z, pid)
    if block.get(x, y, z) == farmlandid then
        block.set_field(x, y, z, "humidity", 4)
        block.set_variant(x, y, z, 1)
    end

    if player.is_infinite_items(pid) then
        return
    end

    local pinvid, slot = player.get_inventory(pid)
    uses = inventory.get_data(pinvid, slot, "uses")

    if uses == 1 then
        local itemid = inventory.get(pinvid, slot)
        inventory.set(pinvid, slot, item.index(string.gsub(item.name(itemid), "_of_water.item", ".item")), 1)
    else
        inventory.use(pinvid, slot)
    end
end

function on_use_on_block(x, y, z, pid)
    local blockid = block.get(x, y, z)
    local block_model = block.properties[blockid]["model-name"]
    if block_model == "crop" then
        watering(x, y - 1, z, pid)
        return true
    end

    watering(x, y, z, pid)
    return true
end