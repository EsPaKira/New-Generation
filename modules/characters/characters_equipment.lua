local characters = require "characters/characters_main"

local equipment = {}
local EQUIPMENT_SLOTS = {"head", "helmet", "body", "chestplate", "cloak", "gloves", "belt", "legs", "greaves", "boots"}


function equipment.equip(pid, character_name, slot, equipment_name, action)
    --action = "equip" or "remove"
    if not equipment.is_correct_slot(slot) then return end

    local character = characters.get_character(pid, character_name)
    if not character then return end

    if not equipment.is_free_slot(character, slot) and action == "remove" then
        characters.set_data(pid, character_name, "equipment", slot, nil)
        equipment.change_stats(pid, character_name, equipment_name, -1)
        return
    elseif not equipment.is_free_slot(character, slot) and action == "equip" then
        characters.set_data(pid, character_name, "equipment", slot, nil)
        equipment.change_stats(pid, character_name, equipment_name, -1)
    end

    characters.set_data(pid, character_name, "equipment", slot, equipment_name)
    equipment.change_stats(pid, character_name, equipment_name, 1)
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
    local find = false
    for _, value in ipairs(EQUIPMENT_SLOTS) do
        if value == slot then
            find = true
            break
        end
    end
    return find
end

function equipment.is_free_slot(character, slot)
    if character.equipment[slot] then return false end
    return true
end

function equipment.get_all_equipment_stats(id)
    return item.properties[id]["newgen:equipment"].protections
end

function equipment.get_equipmennt_stat(id, stat)
    return item.properties[id]["newgen:equipment"].protections[stat]
end

return equipment