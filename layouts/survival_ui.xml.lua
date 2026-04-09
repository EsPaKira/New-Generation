local survival_ui = require "survival_ui"
local characters = require "characters/characters_main"

local function calculate_width(max_width, value, max)
    return math.floor(max_width * value / max);
end

function survival_ui.set_health(health, max_health)
    document["health"].text = health .. "/" .. max_health
    document["health_bar"].size = {calculate_width(240, health, max_health), 25}
end

function survival_ui.set_oxygen(oxygen, max_oxygen)
    document["oxygen"].text = oxygen .. "/" .. max_oxygen
    document["oxygen_bar"].size = {calculate_width(240, oxygen, max_oxygen), 25}

    if oxygen == max_oxygen then
        document["oxygen_bar_root"].visible = false
    else
        document["oxygen_bar_root"].visible = true
    end
end