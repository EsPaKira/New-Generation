local time_under_water = 0

local stats = entity:require_component("newgen:stats")
local SUFFOCATION_DAMAGE = 1000 -- TODO: suffocation damage config


function on_update(tps)
    if time_under_water >= 1 then
        local oxygen = stats:get_oxygen()
        local max_oxygen = stats:get_max_oxygen()

        local health = entity:get_component("newgen:health")
        local swimming = entity:get_component("newgen:swimming")
        local is_head_in_water = swimming.head_underwater(entity:get_uid()) -- TODO: remove this function in module

        if is_head_in_water then
            oxygen = math.max(0, oxygen - 1)
        else 
            oxygen = math.min(max_oxygen, oxygen + 1)
        end
        stats.set_stat("oxygen", oxygen)

        if oxygen == 0 then
            if health then
                health.damage(SUFFOCATION_DAMAGE, "suffocation")
            end
        end

        time_under_water = 0
    end

    time_under_water = time_under_water + 1 / tps
end