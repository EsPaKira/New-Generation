-- simplified scripts/slab.lua from JustBloks

local SLAB_BOTTOM = 4
local SLAB_TOP = 5

local function get_clicked_half(x, y, z, pid)
    local cam = cameras.get(player.get_camera(pid))
    local camPos = cam:get_pos()
    local dir = player.get_dir(pid)
    local raycast = block.raycast(camPos, dir, 100, {})
    if raycast then
        return (raycast.endpoint[2] - raycast.iendpoint[2]) > 0.5 and "top" or "bottom"
    end
    return nil
end

function on_use_on_block(x, y, z, pid, normal)
    local pinvid, slot = player.get_inventory(pid)
    local itemid = inventory.get(pinvid, slot)
    local placing_block = item.placing_block(itemid)

    if block.is_replaceable_at(x, y, z) then
        block.place(x, y, z, placing_block, SLAB_BOTTOM)
        return true
    end

    local whole_block = block.index(block.properties[placing_block]["newgen:full-block"])
    if not whole_block then return end

    if block.get(x, y, z) == placing_block then
        local rot = block.get_rotation(x, y, z)
        if rot ~= 4 and rot ~= 5 then
            block.place(x, y, z, whole_block)
            return true
        end
        if normal[2] == -1 and rot == 5 then
            block.place(x, y, z, whole_block)
            return true
        end
        if normal[2] == 1 and rot == 4 then
            block.place(x, y, z, whole_block)
            return true
        end
    end

    local place_x, place_y, place_z = x + normal[1], y + normal[2], z + normal[3]
    local place = block.get(place_x, place_y, place_z)

    if place ~= 0 and place ~= placing_block and not block.is_replaceable_at(place_x, place_y, place_z) then
        return true
    end

    if place == placing_block then
        block.place(place_x, place_y, place_z, whole_block)
        return true
    end

    local rotation
    if normal[2] > 0 then
        rotation = SLAB_BOTTOM
    elseif normal[2] < 0 then
        rotation = SLAB_TOP
    else
        rotation = (get_clicked_half(x, y, z, pid) == "top") and SLAB_TOP or SLAB_BOTTOM
    end

    block.place(place_x, place_y, place_z, placing_block, rotation)

    if not player.is_infinite_items(pid) then
        inventory.decrement(pinvid, slot, 1)
    end
    return true
end