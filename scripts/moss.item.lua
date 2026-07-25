local red_bricks_id = block.index("newgen:red_bricks")
local mossy_red_bricks_id = block.index("newgen:mossy_red_bricks")

function on_use_on_block(x, y, z, pid)
    if block.get(x, y, z) == red_bricks_id then
        block.place(x, y, z, mossy_red_bricks_id, 0, pid)

        if player.is_infinite_items(pid) then
            return true
        end

        local pinvid, slot = player.get_inventory(pid)
        inventory.decrement(pinvid, slot, 1)
        return true
    end
end