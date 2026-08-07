local characters = require "characters/main"

local equipment = {}
local EQUIPMENT_SLOTS = {"head", "helmet", "body", "chestplate", "cloak", "gloves", "belt", "legs", "greaves", "boots"}


function equipment.equip(pid, character_name, slot, equipment_name, action)
    --action = "equip" or "remove"
    if not equipment.is_correct_slot(slot) then return false end

    local character = characters.get_character(pid, character_name)
    if not character then return false end

    if not equipment.is_valid_equipment(equipment_name, slot) then return false end

    if not equipment.is_free_slot(character, slot) then
        if action == "remove" then
            character.equipment[slot] = nil
            equipment.change_stats(pid, character_name, equipment_name, -1)
            return true
        elseif action == "equip" then
            character.equipment[slot] = nil
            equipment.change_stats(pid, character_name, equipment_name, -1)
        end
    elseif action == "remove" then
        return false
    end

    character.equipment[slot] = equipment_name
    equipment.change_stats(pid, character_name, equipment_name, 1)
    return true
end

function equipment.change_stats(pid, character_name, equipment_name, action)
    --action = 1 or -1
    local equipment_stats = equipment.get_all_equipment_stats(item.index(equipment_name))

    for key, value in pairs(equipment_stats) do
        local old_value = characters.get_field(pid, character_name, "stats", key)
        if old_value then
            characters.set_field(pid, character_name, "stats", key, old_value + (value * action))
        end
    end
end

function equipment.is_correct_slot(slot)
    for _, value in ipairs(EQUIPMENT_SLOTS) do
        if value == slot then return true end
    end
    return false
end

function equipment.is_valid_equipment(equipment_name, slot)
    local itemid = item.index(equipment_name)
    local equipment_data = item.properties[itemid]["newgen:equipment"]
    if not equipment_data then return false end
    if equipment_data.slot ~= slot then return false end
    return true
end

function equipment.is_free_slot(character, slot)
    return character.equipment[slot] == nil
end

function equipment.get_all_equipment_stats(itemid)
    return item.properties[itemid]["newgen:equipment"].protections
end

function equipment.get_equipment_stat(itemid, stat)
    return item.properties[itemid]["newgen:equipment"].protections[stat]
end

function equipment.get_compared_stat(pid, character_name, slot, itemid, stat, is_percent)
    local compare_result = nil
    local equipment_stat = equipment.get_equipment_stat(itemid, stat)
    local equipped_item = equipment.get_equipment_by_slot(pid, character_name, slot)
    local equipped_item_stat = 0
    local result_color = ""

    if equipped_item ~= 0 then 
        equipped_item_stat = item.properties[equipped_item]["newgen:equipment"].protections[stat]
    end

    if equipment_stat > equipped_item_stat then
        result_color = "[#0ee60e]"
    elseif equipment_stat < equipped_item_stat then
        result_color = "[#e60e0e]"
    end

    if is_percent then
        equipment_stat = equipment_stat * 100 .. "%"
    end

    return result_color .. equipment_stat
end

function equipment.get_equipment_by_slot(pid, character_name, slot)
    local equipments = characters.get_group(pid, character_name, "equipment")
    if equipments[slot] == nil then
        return 0
    end
    return item.index(equipments[slot])
end

function equipment.search_equipment_by_tag(invid, tag)
    -- find equipment in inventory
    local found = {}

    for i = 0, inventory.size(invid) - 1 do
        local itemid, _ = inventory.get(invid, i)
        if itemid ~= 0 then
            local equipment = item.properties[itemid]["newgen:equipment"]
            if equipment and equipment.slot == tag then
                table.insert(found, itemid)
            end
        end
    end
    return found
end

return equipment