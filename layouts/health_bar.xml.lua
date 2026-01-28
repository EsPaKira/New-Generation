local survival_hud = require "survival_hud"
local gamemodes = require "gamemodes"

local function calculate_width(max_width, value, max)
    return math.floor(max_width * value / (max or value));
end

function survival_hud.set_health(health, max_health)
    local health_bar_size = document["health_bar"].size

    document["health"].text = health .. "/" .. max_health
    document["health_bar"].size = {calculate_width(240, health, max_health), health_bar_size[2]}
end

function survival_hud.set_oxygen(oxygen, max_oxygen)
    local oxygen_bar_size = document["oxygen_bar"].size

    document["oxygen"].text = oxygen .. "/" .. max_oxygen
    document["oxygen_bar"].size = {calculate_width(240, oxygen, max_oxygen), oxygen_bar_size[2]}

    if oxygen == max_oxygen then
        document["oxygen_bar_root"].visible = false
    else
        document["oxygen_bar_root"].visible = true
    end
end

function on_open()
    local c_manager = gamemodes.get_characteristics_manager(hud.get_player())
    survival_hud.set_health(c_manager.get_health(), c_manager.get_max_health())
    survival_hud.set_oxygen(c_manager.get_oxygen(), c_manager.get_max_oxygen())
end
