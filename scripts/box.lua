function on_interact(x, y, z, pid)
    if block.get_variant(x, y, z) == 0 then
        local GL = require "generate_loot"
        GL.generate_loot(inventory.get_block(x, y, z), "box")
    end

    hud.open_block(x, y, z)
    hud.open_permanent("newgen:player_button")
    block.set_variant(x, y, z, 1)
    return true
end

function on_placed(x, y, z)
    block.set_variant(x, y, z, 1)
end