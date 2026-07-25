local module = {}


function module.try_spawn_at(x, y, z, mob_name, spawn_chance, skeletons)
    local current_time = world.get_day_time()
    if current_time >= 0.166 and current_time <= 0.833 then return end -- if true, then current time is day

    local pid = player.get_nearest({x, y, z})
    if pid then
        local px, py, pz = player.get_pos(pid)
        local dist = vec3.distance({x, y, z}, {px, py, pz})
        if dist < 30 or dist > 50 then return end
        module.spawn(x, y, z, mob_name, spawn_chance, skeletons)
    end
end

function module.spawn(x, y, z, mob_name, spawn_chance, skeletons)
    if random.random(1, 1000) <= spawn_chance then
        local entity = entities.spawn(mob_name, {x, y + 1, z})
        local skeleton = module.choose_skeleton(skeletons)

        if not skeleton then return end

        entity:set_skeleton(skeleton)
    end
end

function module.choose_skeleton(skeletons) -- this function select random variant for entity
    local total_value = 0
    for _, skeleton in ipairs(skeletons) do
        total_value = total_value + skeleton.weight
    end

    local random_value = math.random() * total_value
    local value = 0

    for _, skeleton in ipairs(skeletons) do
        value = value + skeleton.weight
        if random_value <= value then
            return skeleton.name
        end
    end
    return nil
end

return module