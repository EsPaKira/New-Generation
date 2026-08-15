local m = _G["$Multiplayer"]
local block_breaking 


function on_world_open()
    if m.side == "client" then
        block_breaking = require "client/block_breaking"
    end
end

function on_player_tick(pid, tps)
    if m.side == "server" then return end

    if not block_breaking then return end
    block_breaking.player_tick(pid, tps)
end

function on_block_breaking(blockid, x, y, z, pid)
    if not block_breaking then return end
    block_breaking.start_breaking(x, y, z, pid)
end

function on_block_broken(blockid, x, y, z, pid)
    if m.side == "server" then return end

    if not block_breaking then return end
    block_breaking.block_broken(x, y, z, pid)
end