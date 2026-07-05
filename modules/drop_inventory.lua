local base_util = require "base:util"
local gamemodes = require "gamemodes"

local module = {}


local function is_crop(pos)
    local blockid = block.get(pos[1], pos[2], pos[3])
    local block_model = block.properties[blockid]["model-name"]
    if block_model == "crop" then
        local block_v = block.get_variant(pos[1], pos[2], pos[3])
        if block_v == 2 then
            local loot_table = base_util.block_loot(blockid)
            for _, loot in ipairs(loot_table) do
                base_util.drop({pos[1] + 0.5, pos[2] + 0.5, pos[3] + 0.5}, loot.item, loot.count, loot.data)
            end
        end
    end
end

local function is_bucket(pos)
    local blockid = block.get(pos[1], pos[2], pos[3])
    local block_script = block.properties[blockid]["script-name"]
    if block_script == "bucket_block" then
        base_util.drop({pos[1] + 0.5, pos[2] + 0.5, pos[3] + 0.5}, item.index(string.gsub(block.name(blockid) .. ".item", "_of_water.item", ".item")), 1, {})
    end
end

local function is_take_on_interact(pos)
    local blockid = block.get(pos[1], pos[2], pos[3])
    local block_script = block.properties[blockid]["script-name"]
    if block_script == "take_on_interact" then
        base_util.drop({pos[1] + 0.5, pos[2] + 0.5, pos[3] + 0.5}, item.index(block.name(blockid) .. ".item"), 1, {})
    end
end

function module.drop_inventory(invid, pos, power, pid)
    if invid == 0 and gamemodes.get(pid).current == "survival" then
        is_crop(pos)
        is_bucket(pos)
        is_take_on_interact(pos)
        return
    end

    local size = inventory.size(invid)
    for i = 0, size - 1 do
        local itemid, count = inventory.get(invid, i)
        if itemid ~= 0 then
            local data = inventory.get_all_data(invid, i)
            local drop = base_util.drop(pos, itemid, count, data)
            drop.rigidbody:set_vel(vec3.spherical_rand(power))
            inventory.set(invid, i, 0)
        end
    end
end

return module