function on_interact(x, y, z, pid)
    hud.open_block(x, y, z)
    hud.open_permanent("newgen:player_button")
    return true
end