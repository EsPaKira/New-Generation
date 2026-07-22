function on_placed(x, y, z, pid)
    local pinvid, slot = player.get_inventory(pid)
    uses = inventory.get_data(pinvid, slot, "uses") or 1 -- не работает, т.к. предмет исчезает из инвентаря до установки блока

    block.set_field(x, y, z, "uses", uses)
end

function on_interact(x, y, z, pid)
    local pinvid = player.get_inventory(pid)
    local free_slot = inventory.find_by_item(pinvid, 0)
    if free_slot then
        inventory.set(pinvid, free_slot, item.index(block.name(block.get(x, y, z)) .. ".item"), 1)
        local uses = block.get_field(x, y, z, "uses")
        inventory.set_data(pinvid, free_slot, "uses", uses)
        block.destruct(x, y, z, pid)
    end
    return true
end