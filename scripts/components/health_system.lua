-- Original code - base_survival by MihailRis

local gamemodes = require "gamemodes"
local base_util = require "base:util"


local c_manager = entity:require_component("newgen_survival:characteristics_manager")

local health = c_manager:get_health()
local max_health = c_manager:get_max_health()


function set_health(value)
    health = math.min(math.max(0, value), max_health)
    c_manager.set_params("health", health)

    events.emit("newgen_survival:player_health.set", entity:get_uid(), health, max_health)
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
    events.emit("newgen_survival:death", entity)
    events.emit("newgen_survival:player_death", entity:get_player(), true)

    local pid = entity:get_player()
    if not rules.get("keep-inventory") then
        drop_inventory(player.get_inventory(pid))
    end
    entity:despawn()
    player.set_entity(pid, 0)
end

function heal(points)
    local pid = entity:get_player()
    if points < 1 and pid then
        events.emit("newgen_survival:player_heal", pid, points)
    end
    set_health(math.min(health + points, max_health))
end

function damage(points)
    local pid = entity:get_player()
    if gamemodes.get(pid).current == "creative" then
        return
    end
    if points > 0 and pid then
        events.emit("newgen_survival:player_damage", pid, points)
    end
    set_health(health - points)
    if health == 0 then
        die()
    end
end

function on_grounded(force)
    local dmg = math.floor((force - 12) * 1.1)
    damage(math.max(0, math.floor(dmg)))
end