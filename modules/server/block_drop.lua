local base_util = require "base:util"

local module = {}


local function find_loot_by_tag(loot_table, itemid)
    if itemid == 0 then return nil end

    for key, loot in pairs(loot_table) do
        if item.has_tag(itemid, key) then
            return loot
        end
    end
    return nil
end

local function drop_inventory(x, y, z)
    local invid = inventory.get_block(x, y, z)
    if invid == 0 then return end

    for i = 0, inventory.size(invid) - 1 do
        local itemid, count = inventory.get(invid, i)
        if itemid ~= 0 then
            base_util.drop({x + 0.5, y + 0.5, z + 0.5}, itemid, count)
        end
    end
end

function module.drop_block(x, y, z, pid)
    drop_inventory(x, y, z)

    if player.is_instant_destruction(pid) then return end

    module.drop_loot(block.get(x, y, z), x, y, z, pid)
end

function module.drop_loot(blockid, x, y, z, pid)
    if blockid == -1 then return end
    local newgen_loot = block.properties[blockid]["newgen:loot"]
    local loot_table = {}

    if newgen_loot and pid ~= -1 then
        local pinvid, slot = player.get_inventory(pid)
        local itemid = inventory.get(pinvid, slot)
        local matched = find_loot_by_tag(newgen_loot, itemid)
        loot_table = base_util.calc_loot(matched or newgen_loot.default or {})
    else
        loot_table = base_util.block_loot(blockid)
    end

    for _, loot in ipairs(loot_table) do
        base_util.drop({x + 0.5, y + 0.5, z + 0.5}, loot.item, loot.count)
    end
end

return module