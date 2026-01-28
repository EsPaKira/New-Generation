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

function set_equipment(slot, name)
    if equipments[slot] ~= nil then
        equipments[slot] = name
        SAVED_DATA[slot] = name
    end
end