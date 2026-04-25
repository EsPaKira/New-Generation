-- Original code - NotSurvival by kotisoff
-- Protected by MIT license
-- https://github.com/kotisoff/NotSurvival

local survival_ui = require "survival_ui"
local characters = require "characters/characters_main"

local function calculate_width(max_width, value, max)
    return math.floor(max_width * value / max);
end

function survival_ui.set_health(health, max_health)
    document["health"].text = health .. "/" .. max_health
    document["health_bar_curtain"].visible = true
    document["health_bar_curtain"].size = {232 - calculate_width(232, health, max_health), 20}
    document["health_bar_curtain"].pos = {calculate_width(232, health, max_health) + 4, 4}

    if health == max_health then
        document["health_bar_curtain"].visible = false
    end
end

function survival_ui.set_oxygen(oxygen, max_oxygen)
    document["oxygen"].text = oxygen .. "/" .. max_oxygen
    document["oxygen_bar_curtain"].size = {232 - calculate_width(232, oxygen, max_oxygen), 20}
    document["oxygen_bar_curtain"].pos = {calculate_width(232, oxygen, max_oxygen) + 4, 4}

    if oxygen == max_oxygen then
        document["oxygen_bar_root"].visible = false
    else
        document["oxygen_bar_root"].visible = true
    end
end