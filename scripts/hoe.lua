local dirtid = block.index('base:dirt')
local grass_blockid = block.index('base:grass_block')
local farmlandid = block.index("newgen:farmland")

function on_use_on_block(x, y, z, pid)
    local clicked_block = block.get(x, y, z)
    if clicked_block == dirtid or clicked_block == grass_blockid then
        block.place(x, y, z, farmlandid, 0, pid)

        if player.is_infinite_items(pid) then
            return
        end

        local pinvid, slot = player.get_inventory(pid)
        inventory.use(pinvid, slot)
    end
end