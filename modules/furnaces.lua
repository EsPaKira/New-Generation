local furnaces = {
    FURNACES = {}
}
furnaces.crafts = file.read_combined_list("melting_crafts.json")

function furnaces.open(data)
    print(data[1])
    furnaces.FURNACES = data
end

function furnaces.tick() 
    for i, f in ipairs(furnaces.FURNACES) do 
        local fuel_itemid, fuel_count = inventory.get(f[5], 1)

        -- burns fuel
        if f[4][1] <= 0 then
            if fuel_count > 0 then        
                fuel_count = fuel_count - 1
                f[4][1] = item.properties[fuel_itemid]["newgen:material"]["burning-time"]
                f[7] = fuel_itemid
                inventory.set_count(f[5], 1, fuel_count)
            end
        end
        f[4][1] = f[4][1] - 1
        
        -- raises temperature 
        if f[4][1] > 0 and f[4][2] < item.properties[f[7]]["newgen:material"]["max-temperature"] + f[6] then
            f[4][2] = f[4][2] + random.random(2,7)
            if f[4][2] >= item.properties[f[7]]["newgen:material"]["max-temperature"] + f[6] then
                f[4][2] = item.properties[f[7]]["newgen:material"]["max-temperature"] + f[6]
            end
        else
            f[4][2] = f[4][2] - random.random(2,7) * (0.003 * f[4][2])
            f[4][3] = f[4][3] - random.random(2,7) * (0.003 * f[4][3])
        end

        -- melts materials
        if furnaces.temperature_of_melting(f[5]) and f[4][3] < furnaces.temperature_of_melting(f[5]) then
            f[4][3] = f[4][3] + random.random(2,7) * (0.003 * f[4][2])
        else
            furnaces.craft(f[5])
            f[4][3] = 0
        end
        
        -- remove furnace from furnaces if all processes are completed
        if f[4][1] <= 0 and f[4][2] <= 100 and f[4][3] <= 100 then
            block.set_variant(f[1], f[2], f[3], 0)
            furnaces.remove(f[5])
            events.emit("newgen:furnace.remove")
        end
        events.emit("newgen:furnace.update", math.round(f[4][2], 1), math.round(f[4][3], 1), {f[1], f[2], f[3]})
    end
end

function furnaces.add(x, y, z, finvid, f_bonus_temperature) 
    -- {x, y, z, {fuel_burning_time, temperature, melting_progress}, finvid, f_bonus_temperature, fuel_id}
    if not furnaces.contains(finvid) then
        table.insert(furnaces.FURNACES, {x, y, z, {0, 0, 0}, finvid, f_bonus_temperature, fuel_id})
    end
end

function furnaces.remove(finvid)
    if furnaces.contains(finvid) then
        table.remove(furnaces.FURNACES, i)
    end
end

function furnaces.contains(finvid)
    local is_in = false
    for i, f in ipairs(furnaces.FURNACES) do
        if f[5] == finvid then
            is_in = true
            break
        end
    end
    return is_in
end

function furnaces.check(finvid, slot, type) 
    local itemid, count = inventory.get(finvid, slot)

    if item.properties[itemid]["newgen:material"] and item.properties[itemid]["newgen:material"].type == type then
        return true
    end
    return false
end

function furnaces.temperature_of_melting(finvid)
    -- get max melting_temperature in materials
    local material1, _ = inventory.get(finvid, 0)
    -- local material2, _ = inventory.get(finvid, 1)
    -- local material3, _ = inventory.get(finvid, 2)
    if furnaces.check(finvid, 0, "metal") then
        -- if furnaces.check(finvid, 1, "metal") then
        --     if furnaces.check(finvid, 2, "metal") then
        --         return math.max(item.properties[material1]["newgen:material"]["melting-point"], item.properties[material2]["newgen:material"]["melting-point"], item.properties[material3]["newgen:material"]["melting-point"])
        --     end
        --     return math.max(item.properties[material1]["newgen:material"]["melting-point"], item.properties[material2]["newgen:material"]["melting-point"])
        -- end
        return item.properties[material1]["newgen:material"]["melting-point"]
    end
    return nil
end

function furnaces.craft(finvid)
    local material1, count1 = inventory.get(finvid, 0)
    -- local material2, count2 = inventory.get(finvid, 1)
    -- local material3, count3 = inventory.get(finvid, 2)

    local materials = {}

    if furnaces.check(finvid, 0, "metal") then
        table.insert(materials, {material1, count1})
    end
    -- if furnaces.check(finvid, 1, "metal") then
    --     materials[material2] = count2
    -- end
    -- if furnaces.check(finvid, 2, "metal") then
    --     materials[material3] = count3
    -- end

    furnaces.check_crafts(materials, finvid)
end

function furnaces.check_crafts(materials, finvid)
    if #materials == 0 then return end 

    for i, craft in ipairs(furnaces.crafts) do
        for j, comp in ipairs(craft.components or {}) do
            local id = item.index(comp.id)
            if id == materials[1][1] then
                furnaces.melt(finvid, craft)
                return
            end
        end
    end
end

function furnaces.melt(finvid, craft)
    local material, mcount = inventory.get(finvid, 0)
    local result, rcount = inventory.get(finvid, 2)
    local craft_result = item.index(craft.results[1].id)
    mcount = mcount - craft.components[1].count

    if mcount < 0 then return end

    rcount = rcount + craft.results[1].count
    if result ~= 0 then
        if result ~= craft_result then return end

        inventory.set_count(finvid, 0, mcount)
        inventory.set_count(finvid, 2, rcount)
    else
        inventory.set_count(finvid, 0, mcount)
        inventory.set(finvid, 2, craft_result, rcount)
    end
end

function furnaces.get_all_data()
    return furnaces
end

return furnaces