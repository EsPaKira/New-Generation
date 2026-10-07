local m = _G["$Multiplayer"]
if m.side == "client" then return end

local stats = entity:require_component("newgen:stats")
local health_component
local config = require "config"

local hunger_progress = 0
local health_regen_timer = 0
local regen_time = config.main["regen-time"]
local hunger_time = config.main["hunger-time"]


local function set_hunger(value)
    if value == 0 then return end
    if player.is_instant_destruction(entity:get_player()) then return end

    local max_hunger = stats:get_max_hunger()

    stats.set_stat("hunger", math.min(math.max(0, value), max_hunger))
end

local function should_heal()
    local hunger, max_hunger = stats:get_hunger(), stats:get_max_hunger()

    if hunger < max_hunger then return true end
    return false
end

function on_update(tps)
    if hunger_progress >= hunger_time then
        hunger_progress = 0
        set_hunger(stats:get_hunger() + 1)
    end

    if health_regen_timer >= regen_time then
        if not health_component then
            health_component = entity:get_component("newgen:health")
        end

        if health_component then
            if not should_heal() then
                health_regen_timer = 0
                health_component.damage(1, "hunger")
            elseif not health_component.is_full_hp()
            and not health_component.is_in_battle() then
                health_component.heal(1)
                set_hunger(stats:get_hunger() + 1)
            end
        end

        health_regen_timer = 0
    end

    local tick_time = 1 / tps
    health_regen_timer = health_regen_timer + tick_time
    hunger_progress = hunger_progress + tick_time
end

function eat(saturation)
    set_hunger(stats:get_hunger() - saturation)
end

events.on("newgen:heal", function(pid)
    if pid ~= entity:get_player() then return end
    set_hunger(stats:get_hunger() + 1)
end)