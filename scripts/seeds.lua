local farmland_id = block.index("newgen:farmland")

function on_use(pid)
    local pinvid, slot = player.get_inventory()
    local itemid = inventory.get(pinvid, slot)
    local food = item.properties[itemid]["newgen:food"]

    if not food then return end

    local saturation = food["saturation"] or 1
    events.emit("newgen:eat", saturation, pid)

    if player.is_infinite_items(pid) then
        return true
    end

    inventory.decrement(pinvid, slot, 1)
end

function on_use_on_block(x, y, z, pid)
    if block.get(x, y, z) ~= farmland_id then return end

    local block_script = block.properties[block.get(x, y + 1, z)]["script-name"]
    if block_script == "crop" then return end

    local pinvid, slot = player.get_inventory(pid)
    local itemid = inventory.get(pinvid, slot)
    block.place(x, y + 1, z, block.index(item.properties[itemid]["newgen:crop"]), 0, pid)

    if player.is_infinite_items(pid) then
        return
    end

    inventory.decrement(pinvid, slot, 1)
end