depth = 15
local geological_hammers = require "geological_hammers"

function on_use_on_block(x, y, z, pid)
    local pinvid, slot = player.get_inventory(pid)
    inventory.use(pinvid, slot)
    geological_hammers.find_ores(x, y, z, depth)
end