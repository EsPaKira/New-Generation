local geological_hammers = require "geological_hammers"

function on_use_on_block(x, y, z, pid)
    local pinvid, slot = player.get_inventory(pid)
    local itemid = inventory.get(pinvid, slot)
    local depth = item.properties[itemid]["newgen:geological-hammer-depth"] or 15
    geological_hammers.find_ores(x, y, z, depth)

    if player.is_infinite_items(pid) then
        return
    end
    inventory.use(pinvid, slot)
end