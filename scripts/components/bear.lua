local tsf = entity.transform
local mob = entity:require_component("core:mob")
local pathfinding = entity:require_component("core:pathfinding")
local health_system = entity:require_component("newgen:health_system")
local gamemodes = require "gamemodes"

local speed_of_attack = 1
local atack_timer = 0

function on_update(tps)
    local pos = tsf:get_pos()
    local nearest_p = player.get_nearest(pos)
    local px, py, pz = player.get_pos(nearest_p)
    if nearest_p and vec3.distance(pos, {px, py, pz}) < 20 then
        pathfinding.set_target({px, py, pz})
        pathfinding.set_refresh_interval(5)
        mob.look_at({px, py + 1, pz}, true)
        if vec3.distance(pos, {px, py, pz}) < 3 then
            atack_timer = atack_timer + 1 / tps * speed_of_attack
            if atack_timer >= 1 then 
                atack_timer = 0
                attack(player.get_entity(nearest_p))
            end
        end
    else
        pathfinding.set_target(vec3.add(pos, {math.random(-5*3, 5*3), math.random(-2, 2), math.random(-5*3, 5*3)})) 
        pathfinding.set_refresh_interval(300)
        atack_timer = 0
    end

    mob.follow_waypoints()
end

function on_attacked()
    health_system.damage(1)
end

function attack(eid) 
    if eid == player.get_entity(eid) and gamemodes.get(eid).current == "creative" then
        return
    end
    local target = entities.get(eid)
    if target then
        target:get_component("newgen:health_system").damage(1)
    end
end