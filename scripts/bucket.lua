local waterid = block.index("base:water")

function on_use(pid)
    local cam = cameras.get(player.get_camera(pid))
    local camPos = cam:get_pos()
    local dir = player.get_dir(pid)
    local raycast = block.raycast(camPos, dir, 100, {}, {}, true)
    if raycast then
        if raycast.block == waterid then
            local pinvid, slot = player.get_inventory(pid)
            local itemid, count = inventory.get(pinvid, slot)
            if count > 1 then
                local empty_slot = inventory.find_by_item(pinvid, 0)
                if not empty_slot then return true end

                inventory.set(pinvid, empty_slot, item.index(string.gsub(item.name(itemid), ".item", "_of_water.item")), 1)
                inventory.decrement(pinvid, slot, 1)
                return true
            end
            inventory.set(pinvid, slot, item.index(string.gsub(item.name(itemid), ".item", "_of_water.item")), 1)
        end
    end
    return true
end