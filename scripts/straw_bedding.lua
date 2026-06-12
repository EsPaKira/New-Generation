function on_interact(x, y, z, pid)
    player.set_spawnpoint(pid, x, y, z)
    console.chat(gui.str("New spawnpoint at") .. " " .. x .. " " .. y .. " " .. z)
    return true
end