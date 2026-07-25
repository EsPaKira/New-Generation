function on_interact(x, y, z, pid)
    local pinvid = player.get_inventory(pid)
    local free_slot = inventory.find_by_item(pinvid, 0)
    if free_slot then
        inventory.set(pinvid, free_slot, item.index(block.name(block.get(x, y, z)) .. ".item"), 1)
        block.destruct(x, y, z, pid)
    end
    return true
end