local m = _G["$Multiplayer"]
if m.side == "client" then return end

local newgen_utils = require "utils"
local config = require "config"
local stats = entity:require_component("newgen:stats")
local health_component
local eid = entity:get_uid()

local time_under_water = 0
local SUFFOCATION_DAMAGE = config.main["suffocation-damage"]


function on_update(tps)
    if time_under_water >= 1 then
        local oxygen = stats:get_oxygen()
        local max_oxygen = stats:get_max_oxygen()

        local is_head_in_water = newgen_utils.is_head_underwater(eid)

        if is_head_in_water then
            oxygen = math.max(0, oxygen - 1)
        else 
            oxygen = math.min(max_oxygen, oxygen + 1)
        end
        stats.set_stat("oxygen", oxygen)

        if oxygen == 0 then
            if not health_component then
                health_component = entity:get_component("newgen:health")
            end

            if health_component then
                health_component.damage(SUFFOCATION_DAMAGE, "suffocation")
            end
        end

        time_under_water = 0
    end

    time_under_water = time_under_water + 1 / tps
end