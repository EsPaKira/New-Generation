function on_use(pid)
    local pinvid, slot = player.get_inventory()
    local itemid = inventory.get(pinvid, slot)
    local saturation = item.properties[itemid]["newgen:food"]["saturation"] or 0
    events.emit("newgen:eat", saturation, pid)
    inventory.decrement(pinvid, slot, 1)
end