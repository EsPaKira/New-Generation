local base_util = require "base:util"

local module = {}


function module.drop_inventory(invid, pos, power)
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