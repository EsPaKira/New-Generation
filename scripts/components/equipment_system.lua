local c_manager = entity:get_component("newgen_survival:characteristics_manager")

local equipments = {}

local function def_equipment(name, def_value)
    equipments[name] = SAVED_DATA[name] or def_value
    this["get_"..name] = function() return equipments[name] end
end

-- base values; must to be equal 0
def_equipment("head", 0)
def_equipment("helmet", 0)
def_equipment("cloak", 0)
def_equipment("body", 0)
def_equipment("chestplate", 0)
def_equipment("gloves", 0)
def_equipment("legs", 0)
def_equipment("greaves", 0)
def_equipment("belt", 0)
def_equipment("boots", 0)

function set_equipment(slot, id)
    if equipments[slot] ~= nil then
        if equipments[slot] ~= 0 then 
            remove_equipment(slot)
        end
        equipments[slot] = item.name(id)
        SAVED_DATA[slot] = item.name(id)
        equip(slot)
    end
end

function remove_equipment(slot)
    local characteristics = get_all_characteristics_by_slot(slot)
    c_manager.set_params("heat_preservation", c_manager:get_heat_preservation() - characteristics["heat_preservation"])
    c_manager.set_params("heat_reflection", c_manager:get_heat_reflection() - characteristics["heat_reflection"])
    c_manager.set_params("crush_damage_protection", c_manager:get_crush_damage_protection() - characteristics["crush_damage_protection"])
    c_manager.set_params("slashing_damage_protection", c_manager:get_slashing_damage_protection() - characteristics["slashing_damage_protection"])
    c_manager.set_params("piercing_damage_protection", c_manager:get_piercing_damage_protection() - characteristics["piercing_damage_protection"])

    equipments[slot] = 0
    SAVED_DATA[slot] = 0
end

function equip(slot)
    local characteristics = get_all_characteristics_by_slot(slot)
    c_manager.set_params("heat_preservation", c_manager:get_heat_preservation() + characteristics["heat_preservation"])
    c_manager.set_params("heat_reflection", c_manager:get_heat_reflection() + characteristics["heat_reflection"])
    c_manager.set_params("crush_damage_protection", c_manager:get_crush_damage_protection() + characteristics["crush_damage_protection"])
    c_manager.set_params("slashing_damage_protection", c_manager:get_slashing_damage_protection() + characteristics["slashing_damage_protection"])
    c_manager.set_params("piercing_damage_protection", c_manager:get_piercing_damage_protection() + characteristics["piercing_damage_protection"])
end

function get_all_characteristics_by_slot(slot)
    return item.properties[item.index(equipments[slot])]["newgen_survival:equipment"].protections
end

function get_characteristic_by_slot(slot, type_of_protection)
    return item.properties[item.index(equipments[slot])]["newgen_survival:equipment"].protections[type_of_protection]
end

function get_item_by_slot(slot)
    if equipments[slot] == 0 then
        return 0
    end
    return item.index(equipments[slot])
end