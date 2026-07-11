local gamemodes = require "gamemodes"
local characters = require "characters/main"

local c_manager = entity:require_component("newgen:characteristics_manager")

local hunger = c_manager:get_hunger()
local max_hunger = c_manager:get_max_hunger()


function load_hunger()
    c_manager.is_player() -- update all stats if this entity is player
    hunger = c_manager:get_hunger()
    max_hunger = c_manager:get_max_hunger()
end

function set_hunger(value)
    hunger = math.min(math.max(0, value), max_hunger)
    local is_player, character_name = c_manager.is_player()
    if is_player then
        characters.set_field(hud.get_player(), character_name, "stats", "hunger", hunger)
        events.emit("newgen:player_hunger.set", entity:get_uid(), hunger, max_hunger)
    else
        c_manager.set_params("hunger", hunger)
    end
end

local hunger_progress = 0
function on_update(tps)
    if hunger_progress >= 120 then
        load_hunger()
        set_hunger(hunger + 1)
        hunger_progress = 0
    end
    hunger_progress = hunger_progress + 1 / tps
end

events.on("newgen:heal", function()
    load_hunger()
    set_hunger(hunger + 1)
end)

events.on("newgen:eat", function(hunger_restored)
    load_hunger()
    set_hunger(hunger - hunger_restored)
end)