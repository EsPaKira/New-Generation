local m = _G["$Multiplayer"]
local crafting = m.side == "server" and require "crafting" or nil

function on_interact(x, y, z, pid)
    if m.side == "client" then
        local category = block.properties[block.get(x, y, z)]["newgen:workbench-category"]
        if category then
            hud.show_overlay("newgen:crafts", false, {category})
        end
        return true
    end

    crafting.open_station(x, y, z, pid)
end
