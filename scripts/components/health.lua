-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival
local m = _G["$Multiplayer"]
if m.side == "client" then return end

local stats = entity:require_component("newgen:stats")
local newgen_utils = require "utils"
local respawn = require "respawn"
local config = require "config"

local tsf = entity.transform
local eid = entity:get_uid()
local in_battle_timer = 0
local max_fall_y = nil
local in_battle_time = config.main["in-battle-time"]


local function die()
    local pid = entity:get_player()
    if pid == -1 then
        local loot = entity:get_component("newgen:loot")
        if loot then
            loot.drop_loot()
        end

        return
    end

    stats.set_stat("is_dead", true)
    respawn.notify_death(eid)
end

local function set_health(value)
    local health = stats:get_hp()
    local max_health = stats:get_max_hp()

    health = math.min(math.max(0, health - value), max_health)
    stats.set_stat("hp", health)

    if health == 0 then
        die()
    end
end

local function calculate_damage(points, type)
    -- if type == "falling" or type == "suffocation" or type == "hunger" then return points end
    -- local protection = c_manager["get_" .. type .. "_damage_protection"]()
    -- return math.round(math.max(0, (points - c_manager:get_absolute_damage_protection()) * (1 - protection)))
    return points
end

function heal(points)
    if points == 0 then return end
    set_health(-points)
end

function damage(points, type)
    if points == 0 then return end

    local pid = entity:get_player()
    if pid ~= -1 and player.is_instant_destruction(pid) then
        return
    end

    in_battle_timer = in_battle_time

    local end_damage = calculate_damage(points, type)

    set_health(end_damage)
end

function is_in_battle()
    return in_battle_timer > 0
end

function is_full_hp()
    local hp, max_hp = stats:get_hp(), stats:get_max_hp()
    return hp == max_hp
end

function on_update(tps)
    if newgen_utils.is_in_water(eid) then
        max_fall_y = nil
    else
        local y = tsf:get_pos()[2]
        if max_fall_y == nil or y > max_fall_y then
            max_fall_y = y
        end
    end

    in_battle_timer = in_battle_timer - 1 / tps
end

function on_grounded()
    if newgen_utils.is_in_water(eid) then
        max_fall_y = nil
        return
    end

    local y = tsf:get_pos()[2]
    local height = (max_fall_y or y) - y
    max_fall_y = nil

    if height <= 0 then return end

    local dmg = math.max(0, math.floor((height - 3.9)))
    damage(dmg, "falling")
end