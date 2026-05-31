local tsf = entity.transform
local mob = entity:require_component("core:mob")
local pathfinding = entity:require_component("core:pathfinding")
local health_system = entity:require_component("newgen:health_system")
local gamemodes = require "gamemodes"

local speed_of_attack = 1
local atack_timer = 0
local sound_timer = 0
local rand_sound = (random.random(30, 60)/10)

function on_update(tps)
    local pos = tsf:get_pos()
    local nearest_p = player.get_nearest(pos)
    local px, py, pz = player.get_pos(nearest_p)
    if nearest_p and vec3.distance(pos, {px, py, pz}) < 20 then
        pathfinding.set_target({px, py, pz})
        pathfinding.set_refresh_interval(5)
        mob.look_at({px, py + 1, pz}, true)
        if vec3.distance(pos, {px, py, pz}) < 2 then
            atack_timer = atack_timer + 1 / tps * speed_of_attack
            if atack_timer >= 1 then 
                atack_timer = 0
                attack(nearest_p)
            end
        end
    else
        pathfinding.set_target(vec3.add(pos, {math.random(-5*3, 5*3), math.random(-2, 2), math.random(-5*3, 5*3)})) 
        pathfinding.set_refresh_interval(300)
        atack_timer = 0
    end

    sound_timer = sound_timer + 1 / tps
    if sound_timer >= rand_sound then
        audio.play_sound("entities/spider", pos[1], pos[2], pos[3], random.random(), 1)
        sound_timer = 0
        rand_sound = (random.random(30, 60)/10)
    end
    mob.follow_waypoints()
end

function on_attacked(eid, pid)
    local invid, slot = player.get_inventory(pid)
    local itemid, _ = inventory.get(invid, slot)
    local tool = item.properties[itemid]["newgen:tool"]
    local type_of_damage = "crushing"
    local total_damage = 2
    if tool then
        type_of_damage = tool.damage[1].type
        total_damage = total_damage + tool.damage[1].count
    end

    local c_manager = entities.get(eid):require_component("newgen:characteristics_manager")
    total_damage = total_damage + c_manager:get_body_level()

    local pos = tsf:get_pos()
    audio.play_sound("entities/spider_damage", pos[1], pos[2], pos[3], random.random(), 1)

    health_system.damage(total_damage, type_of_damage)
end

function attack(pid) 
    if gamemodes.get(pid).current == "creative" then
        return
    end
    local target = entities.get(player.get_entity(pid))
    if target then
        local pos = tsf:get_pos()
        audio.play_sound("entities/spider_attack", pos[1], pos[2], pos[3], random.random(), 1)
        target:get_component("newgen:health_system").damage(10, "piercing")
    end
end