-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival

local crafting = {
    crafts = {}
}

function crafting.update_crafts()
    local all_crafts = file.list_all_res("crafts")
    for i, craft in ipairs(all_crafts) do
        -- craft = PACK_ID:crafts/file_name.json

        local craft_name = craft:match("([^/]+)$"):match("^(.*)%.") -- get file_name
        if not crafting.crafts[craft_name] then
            crafting.crafts[craft_name] = file.read_combined_list(craft:match("([^:]+)$"))
        end
    end
end

function crafting.find_all_containing(id, craft_material, craft_name)
    -- находит все совпадения в компонентах крафта по ID предмета или по материалу
    local found = {}
    for _, craft in ipairs(crafting.crafts[craft_name]) do
        for _, comp in ipairs(craft.components or {}) do
            if craft_material and comp.tag ~= nil then
                if craft_material == comp.tag then
                    table.insert(found, craft)
                    break
                end
            end
            if comp.id == id then
                table.insert(found, craft)
                break
            end
        end
    end
    return found
end

function crafting.find_all_results(id)
    -- находит все совпадения в результатах всех зашруженных крафтов по ID предмета
    local found = {}
    for key, craft_group in pairs(crafting.crafts) do
        for _, craft in ipairs(craft_group) do
            for _, results in ipairs(craft.results or {}) do
                if results.id == id then
                    table.insert(found, {key, craft})
                    break
                end
            end
        end
    end
    return found
end

function crafting.is_enough(craft, stats)
    for i, comp in ipairs(craft.components) do
        if comp.tag then 
            if (stats[comp.tag] or 0) < comp.count then
                return false
            end
        else
            local id = item.index(comp.id)
            if (stats[id] or 0) < comp.count then
                return false
            end
        end
    end
    return true
end

local function remove_item(invid, itemid, itemcount)
    local size = inventory.size(invid)
    for i = 0, size - 1 do
        local id, count = inventory.get(invid, i)
        if id == itemid then
            local decrement = math.min(itemcount, count)
            inventory.decrement(invid, i, decrement)
        end
    end
end

local function remove_items_by_tag(invid, tag, itemcount)
    local size = inventory.size(invid)
    for i = 0, size - 1 do
        if itemcount <= 0 then
            break
        end

        local id, count = inventory.get(invid, i)
        craft_material = item.properties[id]["newgen:craft-material"]
        if craft_material == tag then
            local decrement = math.min(itemcount, count)
            inventory.decrement(invid, i, decrement)
            itemcount = itemcount - decrement
        end
    end
end

function crafting.remove_from(craft, invid)
    for i, comp in ipairs(craft.components) do
        if comp.tag then
            remove_items_by_tag(invid, comp.tag, comp.count)
        else
            remove_item(invid, item.index(comp.id), comp.count)
        end 
    end
end

return crafting