local module = {
    temp_count = 0
}


local function is_possible_to_generate(invid)
    local size = inventory.size(invid)
    for i = 0, size - 1 do
        local itemid, count = inventory.get(invid, i)
        if itemid ~= 0 then
            return false
        end
    end
    return true
end

local function is_free_space(invid)
    local size = inventory.size(invid)
    for i = 0, size - 1 do
        local itemid, count = inventory.get(invid, i)
        if itemid == 0 then
            return true
        end
    end
    return false
end

local function place_item(invid, itemid, count, max_slots)
    local size = inventory.size(invid)
    local rand = random.random(0, size - 1)
    local id, _ = inventory.get(invid, rand)

    if count > 1 and (max_slots or 1) > 1 then
        local temp_count = random.random(1, count)
        module.temp_count = count - temp_count
        inventory.set(invid, rand, itemid, temp_count)
        place_item(invid, itemid, module.temp_count, (max_slots - 1))
        return
    end

    if id == 0 then
        inventory.set(invid, rand, itemid, count)
    else
        place_item(invid, itemid, count)
    end
end

function module.generate_loot(invid, blockid)
    if is_possible_to_generate(invid) then
        local loot = file.read_combined_list("blocks_loot/" .. blockid .. ".json") or {}
        
        for _, field in ipairs(loot) do
            if is_free_space(invid) then
                place_item(invid, item.index(field.item), random.random(field.min, field.max), field["max-slots"])
            else
                break
            end
        end
    end
end

return module