-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival

local gamemodes = require "gamemodes"
local DI = require "drop_inventory"
local characters = require "characters/characters_main"


local c_manager = entity:require_component("newgen:characteristics_manager")

local health = c_manager:get_health()
local max_health = c_manager:get_max_health()

local health_regen_timer = 0
local in_battle_timer = 0


function load_health()
    c_manager.is_player() -- update all stats if this entity is player
    health = c_manager:get_health()
    max_health = c_manager:get_max_health()
end

function set_health(value)
    if value == health then return end
    health = math.min(math.max(0, value), max_health)
    local is_player, character_name = c_manager.is_player()

    if is_player then
        characters.set_field(hud.get_player(), character_name, "stats", "health", health)
        events.emit("newgen:player_health.set", entity:get_uid(), health, max_health)
    else
        c_manager.set_params("health", health)
    end
end

function die()
    local tsf = entity.transform
    events.emit("newgen:death", tsf:get_pos())

    local pid = entity:get_player()
    if pid == -1 then
        local loot = entity:get_component("newgen:loot")
        if loot then
            loot.drop_loot()
        end
        entity:despawn()
        return
    end

    events.emit("newgen:player_death", entity:get_player(), true)
    if not rules.get("keep-inventory") then
        DI.drop_inventory(player.get_inventory(pid), entity.transform:get_pos(), 8)
    end
    entity:despawn()
    player.set_entity(pid, 0)
end

function heal(points)
    set_health(math.min(health + points, max_health))
end

local function calculate_damage(points, type)
    if type == "falling" then return points end
    if type == "suffocation" then return points end
    local protection = c_manager["get_" .. type .. "_damage_protection"]()
    return math.round(math.max(0, (points - c_manager:get_absolute_damage_protection()) * (1 - protection)))
end

function damage(points, type)
    if points == 0 then return end
    local pid = entity:get_player()
    if pid and gamemodes.get(pid).current == "creative" then
        return
    end

    in_battle_timer = 10

    if pid then
        events.emit("newgen:player_damage", pid)
    end
    local end_damage = calculate_damage(points, type)

    load_health()
    set_health(health - end_damage)
    if health == 0 then
        die()
        characters.set_field(pid, characters.get_choosen_character(pid), "stats", "health", characters.get_field(pid, characters.get_choosen_character(pid), "stats", "max_health")) -- set health after death
    end
end

function on_update(tps)
    if health_regen_timer >= 1 and in_battle_timer == 0 then
        heal(1)
        health_regen_timer = 0
    end

    health_regen_timer = health_regen_timer + 1 / tps
    in_battle_timer = math.max(0, in_battle_timer - 1 / tps)
end

function on_grounded(force)
    local dmg = math.floor((force - 13) * 1.1)
    damage(math.max(0, math.floor(dmg)), "falling")
end