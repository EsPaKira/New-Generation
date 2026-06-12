local spawners = {
    data = {
        SPAWNERS = {}, -- {x, y, z, entities{} }, ...
        ENTITIES = {} -- {entity, x, y, z}, ... maybe not good solution
    }
}
local module = {}


function module.open(data)
    spawners.data = data
end

function module.add_spawner(x, y, z)
    if not module.is_spawner_exists(x, y, z) then
        table.insert(spawners.data.SPAWNERS, {x, y, z, {} })
    end
end

function module.remove_spawner(x, y, z)
    local _, spawner_pos_in_arr = module.get_spawner(x, y, z)
    if spawner_pos_in_arr then 
        table.remove(spawners.data.SPAWNERS, spawner_pos_in_arr)
    end
end

function module.add_entity(x, y, z, eid)
    if module.is_entity_exists(eid) then return end
    
    local spawner = module.get_spawner(x, y, z)
    if spawner then
        table.insert(spawner[4], eid)
        table.insert(spawners.data.ENTITIES, {eid, x, y, z})
    end
end

function module.remove_entity(eid)
    local ENTITY, entity_pos_in_arr = module.get_entity(eid)

    if entity_pos_in_arr then
        table.remove(spawners.data.ENTITIES, entity_pos_in_arr)
        local spawner = module.get_spawner(ENTITY[2], ENTITY[3], ENTITY[4])

        if spawner then
            local e_pos = module.get_entity_in_spawner(eid, spawner)
            if e_pos then
                table.remove(spawner[4], e_pos)
            end
        end
    end
end

function module.get_spawner(x, y, z)
    for i, spawner in ipairs(spawners.data.SPAWNERS) do
        if spawner[1] == x and spawner[2] == y and spawner[3] == z then
            return spawner, i
        end
    end
    return nil
end

function module.get_entity(eid)
    for i, ENTITY in ipairs(spawners.data.ENTITIES) do
        if ENTITY[1] == eid then
            return ENTITY, i
        end
    end
    return nil
end

function module.get_entity_in_spawner(eid, spawner)
    for i, id in ipairs(spawner[4]) do
        if id == eid then
            return i
        end
    end
    return nil
end

function module.is_spawner_exists(x, y, z)
    for i, spawner in ipairs(spawners.data.SPAWNERS) do
        if spawner[1] == x and spawner[2] == y and spawner[3] == z then
            return true, i
        end
    end
    return false
end

function module.is_entity_exists(eid)
    for i, ENTITY in ipairs(spawners.data.ENTITIES) do
        if ENTITY[1] == eid then
            return true, i
        end
    end
    return false
end

events.on("newgen:death", function(pos, entity)
    module.remove_entity(entity:get_uid())
end)

function module.get_all_data()
    return spawners
end

return module