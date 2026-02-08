function on_interact(x, y, z, playerid)
    local blackberry_slot = inventory.find_by_item(player.get_inventory(playerid), item.index("newgen:blackberry"))
    local free_slot = inventory.find_by_item(player.get_inventory(playerid), 0)
    if blackberry_slot ~= nil or free_slot ~= nil then
        block.set_variant(x, y, z, 1)
        inventory.add(player.get_inventory(playerid), item.index("newgen:blackberry"), random.random(2,5))
        return
    end
end

function on_random_update(x, y, z)
    block.set_variant(x, y, z, 0)
end