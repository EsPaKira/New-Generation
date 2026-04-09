local gamemodes = require "gamemodes"
local characters = require "characters/characters_main"

local c_manager = entity:require_component("newgen:characteristics_manager")

local oxygen = c_manager:get_oxygen()
local max_oxygen = c_manager:get_max_oxygen()


function load_oxygen()
    if c_manager.is_player() then
        oxygen = c_manager:get_oxygen()
        max_oxygen = c_manager:get_max_oxygen()
    end
end

function set_oxygen(value)
    load_oxygen()
    oxygen = math.min(math.max(0, value), max_oxygen)
    local is_player, character_name = c_manager.is_player()
    if is_player then
        characters.set_field(hud.get_player(), character_name, "stats", "oxygen", oxygen)
        events.emit("newgen:player_oxygen.set", entity:get_uid(), oxygen, max_oxygen)
    else
        c_manager.set_params("oxygen", oxygen)
    end
end

local time_under_water = 0
function on_update(tps)
    if entity:get_player() then
        if gamemodes.get(entity:get_uid()).current ~= "survival" then
            return
        end
    end

    if time_under_water >= 1 then
        local health = entity:get_component("newgen:health_system")
        local swimming = entity:get_component("newgen:swimming_system")
        local is_head_in_water = swimming.head_underwater(entity:get_uid())
        if is_head_in_water then
            set_oxygen(oxygen - 1)
        else 
            set_oxygen(oxygen + 1)
        end
        if oxygen == 0 then
            health.die()
        end
        time_under_water = 0
    end
    time_under_water = time_under_water + 1 / tps
end