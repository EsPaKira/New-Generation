local m = _G["$Multiplayer"]
local block_breaking
local block_drop
local player_loaded = false


function on_world_open()
    if m.side == "server" then
        block_drop = require "server/block_drop"
    else
        block_breaking = require "client/block_breaking"
    end
end

if m.side == "client" then
    function on_player_tick(pid)
        if not player_loaded then
            events.emit("newgen:player_loaded", pid)
            player_loaded = true
        end

        if not block_breaking then return end
        block_breaking.player_tick(pid)
    end
end

function on_block_breaking(blockid, x, y, z, pid)
    if not block_breaking then return end
    block_breaking.start_breaking(x, y, z, pid)
end

function on_block_broken(blockid, x, y, z, pid)
    if m.side == "server" then
        if pid == -1 then
            if not block_drop then return end
            block_drop.drop_loot(blockid, x, y, z, pid)
        end
        return
    end

    if not block_breaking then return end
    block_breaking.block_broken()
end