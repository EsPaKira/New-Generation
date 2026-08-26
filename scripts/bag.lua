local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local block_drop = m.side == "server" and require "server/block_drop" or nil

function on_interact(x, y, z, pid)
    if m.side == "client" then return end

    local player_obj = api.sandbox.players.get_by_pid(pid)
    api.sandbox.inventories.open_block(player_obj, {x, y, z})
    return true
end

function on_breaking(x, y, z, pid)
    if m.side == "client" then return end
    if player.is_instant_destruction(pid) then
        block_drop.drop_block(x, y, z, pid)
    end
end