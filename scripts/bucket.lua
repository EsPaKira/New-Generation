function on_use(pid)
    local cam = cameras.get(player.get_camera(pid))
    local camPos = cam:get_pos()
    local dir = player.get_dir(pid)
    local raycast = block.raycast(camPos, dir, 100, {}, {}, true)
    if raycast then
        if raycast.block == block.index("base:water") then
            local pinvid, slot = player.get_inventory(pid)
            local itemid = inventory.get(pinvid, slot)
            inventory.set(pinvid, slot, item.index(string.gsub(item.name(itemid), ".item", "_of_water.item")), 1)
        end
    end
    return true
end