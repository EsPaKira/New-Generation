local base_util = require "base:util"


local loot_table = ARGS.loot_table

function drop_loot()
    local pos = entity.transform:get_pos()
    local loot_result = calc_loot()
    for _, loot in ipairs(loot_result) do
        if loot.item ~= 0 then
            local drop = base_util.drop(pos, loot.item, loot.count)
            drop.rigidbody:set_vel(vec3.spherical_rand(8.0))
        end
    end
end

-- this function is local in base:util
function calc_loot()
    local results = {}
    for _, loot in ipairs(loot_table) do
        local chance = loot.chance or 1
        local count = loot.count or 1
        
        local roll = math.random()
        
        if roll < chance then
            if loot.min and loot.max then
                count = math.random(loot.min, loot.max)
            end
            if count == 0 then
                goto continue
            end
            table.insert(results, {item=item.index(loot.item), count=count})
        end
        ::continue::
    end
    return results
end