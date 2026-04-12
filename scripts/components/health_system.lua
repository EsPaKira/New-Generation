-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival

local gamemodes = require "gamemodes"
local base_util = require "base:util"
local characters = require "characters/characters_main"


local c_manager = entity:require_component("newgen:characteristics_manager")

local health = c_manager:get_health()
local max_health = c_manager:get_max_health()


function load_health()
    if c_manager.is_player() then
        health = c_manager:get_health()
        max_health = c_manager:get_max_health()
    end
end

function set_health(value)
    if value == health then return end
    load_health()
    health = math.min(math.max(0, value), max_health)
    local is_player, character_name = c_manager.is_player()

    if is_player then
        characters.set_field(hud.get_player(), character_name, "stats", "health", health)
        events.emit("newgen:player_health.set", entity:get_uid(), health, max_health)
    else
        c_manager.set_params("health", health)
    end
end

local function drop_inventory(invid)
    local pos = entity.transform:get_pos()
    local size = inventory.size(invid)
    for i=0,size-1 do
        local itemid, count = inventory.get(invid, i)
        if itemid ~= 0 then
            local data = inventory.get_all_data(invid, i)
            local drop = base_util.drop(pos, itemid, count, data)
            drop.rigidbody:set_vel(vec3.spherical_rand(8.0))
            inventory.set(invid, i, 0)
        end
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
        drop_inventory(player.get_inventory(pid))
    end
    entity:despawn()
    player.set_entity(pid, 0)
end

function heal(points)
    set_health(math.min(health + points, max_health))
end

function damage(points)
    local pid = entity:get_player()
    if pid and gamemodes.get(pid).current == "creative" then
        return
    end
    if points > 0 and pid then
        events.emit("newgen:player_damage", pid, points)
    end
    set_health(health - points)
    if health == 0 then
        die()
        characters.set_field(pid, characters.get_choosen_character(pid), "stats", "health", characters.get_field(pid, characters.get_choosen_character(pid), "stats", "max_health"))
    end
end

function on_grounded(force)
    local dmg = math.floor((force - 12) * 1.1)
    damage(math.max(0, math.floor(dmg)))
end