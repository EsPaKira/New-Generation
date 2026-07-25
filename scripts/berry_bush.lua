function on_interact(x, y, z, playerid)
    if block.get_variant(x, y, z) == 0 then return end

    local berries = block.properties[block.get(x, y, z)]["newgen:berries"]
    local berry_id = item.index(berries)
    local berry_slot = inventory.find_by_item(player.get_inventory(playerid), berry_id)
    local free_slot = inventory.find_by_item(player.get_inventory(playerid), 0)
    if berry_slot ~= nil or free_slot ~= nil then
        block.set_variant(x, y, z, 0)
        inventory.add(player.get_inventory(playerid), berry_id, random.random(2,5))
        return
    end
end

function on_random_update(x, y, z)
    block.set_variant(x, y, z, 1)
end