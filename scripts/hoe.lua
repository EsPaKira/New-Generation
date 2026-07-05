function on_use_on_block(x, y, z, pid)
    local clicked_block = block.get(x, y, z)
    if clicked_block == block.index("base:dirt") or clicked_block == block.index("base:grass_block") then
        block.place(x, y, z, block.index("newgen:farmland"), 0, pid)

        if player.is_infinite_items(pid) then
            return
        end

        local pinvid, slot = player.get_inventory(pid)
        inventory.use(pinvid, slot)
    end
end