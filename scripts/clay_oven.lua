local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local furnaces = m.side == "server" and require "server/furnaces" or nil
local block_drop = m.side == "server" and require "server/block_drop" or nil

local TORCH = item.index("base:torch.item")

local function holds_torch(pid)
    local pinvid, slot = player.get_inventory(pid)
    local itemid = inventory.get(pinvid, slot)
    return itemid == TORCH
end

function on_interact(x, y, z, pid)
    if m.side == "client" then
        if not holds_torch(pid) then
            events.emit("newgen:block_open")
        end
        return true
    end

    if holds_torch(pid) and furnaces.ignite(x, y, z) then
        return true
    end

    local player_obj = api.sandbox.players.get_by_pid(pid)
    api.sandbox.inventories.open_block(player_obj, {x, y, z})
end

function on_breaking(x, y, z, pid)
    if m.side == "client" then return end
    if player.is_instant_destruction(pid) then
        block_drop.drop_block(x, y, z, pid)
    end
end

function on_broken(x, y, z)
    if m.side == "server" then
        furnaces.remove(x, y, z)
    end
end

-- events.on("newgen:furnace.update", function(t, m, pos)
--     if random.random(1, 10) > 7 then 
--         pos[2] = pos[2] + 1
--         pos[1] = pos[1] + 0.5
--         pos[3] = pos[3] + 0.5
--         gfx.particles.emit(pos, 4, {
--             lifetime = 9,
--             lifetime_spread = 1,
--             spawn_interval = 0.0001,
--             explosion = {0.2, 2, 0.2},
--             angle_spread = 0.05,
--             velocity = {0, 0.3, 0},
--             acceleration = {0, -0.1, 0},
--             size = {0.4, 0.4, 0.4},
--             spawn_shape = "box",
--             spawn_spread = {0.1, 0.1, 0.1},
--             lighting = false,
--             collision = true,
--             frames = {
--                 "particles:smoke_0",
--                 "particles:smoke_1"
--             }
--         })
--     end
-- end)
