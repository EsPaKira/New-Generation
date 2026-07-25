-- Original code - NotSurvival by kotisoff
-- Protected by MIT license
-- https://github.com/kotisoff/NotSurvival

local survival_ui = require "survival_ui"

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

-- ------ --
-- HUNGER --
-- ------ --

local hunger_at_100 = {41, 9, 9, 255}
local hunger_at_75 = {188, 32, 35, 255}
local hunger_at_50 = {235, 68, 44, 255}
local hunger_at_25 = {248, 179, 36, 255}
local hunger_at_0 = {59, 97, 15, 255}

function survival_ui.set_hunger(hunger, max_hunger)
    local ratio = hunger / max_hunger * 100

    document["hunger_tooltip"].tooltip = gui.str("Hunger") .. ": " .. ratio .. "%"

    if ratio == 100 then
        document["hunger"].color = hunger_at_100
    elseif ratio >= 75 then
        document["hunger"].color = hunger_at_75
    elseif ratio >= 50 then
        document["hunger"].color = hunger_at_50
    elseif ratio >= 25 then
        document["hunger"].color = hunger_at_25
    else
        document["hunger"].color = hunger_at_0
    end
end