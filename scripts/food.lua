function on_use(pid)
    local pinvid, slot = player.get_inventory()
    local itemid = inventory.get(pinvid, slot)
    local saturation = item.properties[itemid]["newgen:food"]["saturation"] or 0
    events.emit("newgen:eat", saturation, pid)

    if player.is_infinite_items(pid) then
        return true
    end

    inventory.decrement(pinvid, slot, 1)
    return true
end