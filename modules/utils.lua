local water_id = block.index("base:water")

local module = {}


local function entity_pos(eid)
    local entity = entities.get(eid)
    local pos = entity.transform:get_pos()
    pos[1] = math.floor(pos[1])
    pos[3] = math.floor(pos[3])
    return pos
end

function module.is_in_water(eid)
    local pos = entity_pos(eid)
    return block.get(pos[1], pos[2] - 0.3, pos[3]) == water_id or block.get(pos[1], pos[2] + 1, pos[3]) == water_id
end

function module.is_head_underwater(eid)
    local pos = entity_pos(eid)
    return block.get(pos[1], pos[2] + 0.8, pos[3]) == water_id
end

function module.is_body_underwater(eid)
    local pos = entity_pos(eid)
    return block.get(pos[1], pos[2], pos[3]) == water_id
end

return module