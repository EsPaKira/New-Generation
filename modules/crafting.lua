-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival

local crafting = {}

function crafting.add_workbench_crafts(name)
    crafting.crafts = nil
    crafting.crafts = file.read_combined_list("crafts/primitive_crafts.json")
    if name ~= 0 then
        table.merge(crafting.crafts, file.read_combined_list("crafts/" .. name .. "_crafts.json"))
    end
end

function crafting.find_all_containing(id, craft_material)
    local found = {}
    for i, craft in ipairs(crafting.crafts) do
        for j, comp in ipairs(craft.components or {}) do
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