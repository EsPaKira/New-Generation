local newgen_utils = require "utils"
local stats = entity:require_component("newgen:stats")

local time_under_water = 0
local SUFFOCATION_DAMAGE = 1000 -- TODO: suffocation damage config


function on_update(tps)
    if time_under_water >= 1 then
        local oxygen = stats:get_oxygen()
        local max_oxygen = stats:get_max_oxygen()

        local is_head_in_water = newgen_utils.is_head_underwater(entity:get_uid())

        if is_head_in_water then
            oxygen = math.max(0, oxygen - 1)
        else 
            oxygen = math.min(max_oxygen, oxygen + 1)
        end
        stats.set_stat("oxygen", oxygen)

        if oxygen == 0 then
            local health = entity:get_component("newgen:health")
            if health then
                health.damage(SUFFOCATION_DAMAGE, "suffocation")
            end
        end

        time_under_water = 0
    end

    time_under_water = time_under_water + 1 / tps
end