local equipment_search = {}

function equipment_search.search_equipment_by_tag(invid, tag)
    local found = {}

    for i = 0, inventory.size(invid) - 1 do
        local id, _ = inventory.get(invid, i)
        if id ~= 0 then
            local equipment = item.properties[id]["newgen:equipment"]
            if equipment and equipment.slot == tag then
                table.insert(found, id)
            end
        end
    end
    return found
end

function equipment_search.get_equipment_system(pid)
    local entity = entities.get(player.get_entity(pid))
    if entity == nil then
        return nil
    end
    return entity:get_component("newgen:equipment_system")
end

function equipment_search.get_equipment_characteristics(id, slot, pid, type_of_protection)
    local compared_property = equipment_search.compare_with_equipped(item.properties[id]["newgen:equipment"].protections, slot, pid, type_of_protection)
    return compared_property
end

function equipment_search.compare_with_equipped(protections, slot, pid, type_of_protection)
    local compared_property = nil
    local equipped_item = 0
    if equipment_search.get_equipment_system(pid).get_item_by_slot(slot) ~= 0 then
        equipped_item = equipment_search.get_equipment_system(pid).get_characteristic_by_slot(slot, type_of_protection)
    end

    if protections[type_of_protection] > equipped_item then
        compared_property = "[#0ee60e]" .. protections[type_of_protection]
    elseif protections[type_of_protection] < equipped_item then
        compared_property = "[#e60e0e]" .. protections[type_of_protection]
    else
        compared_property = protections[type_of_protection]
    end

    return compared_property
end

return equipment_search