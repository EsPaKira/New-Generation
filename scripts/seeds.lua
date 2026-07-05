function on_use_on_block(x, y, z, pid)
    if block.get(x, y, z) ~= block.index("newgen:farmland") then return end
    local pinvid, slot = player.get_inventory(pid)
    local itemid = inventory.get(pinvid, slot)
    block.place(x, y + 1, z, block.index(item.properties[itemid]["newgen:crop"]), 0, pid)

    if not player.is_infinite_items(pid) then
        inventory.decrement(pinvid, slot, 1)
    end
end