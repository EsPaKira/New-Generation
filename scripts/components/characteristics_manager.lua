local characteristics = {}

local function def_characteristics(name, def_value)
    characteristics[name] = SAVED_DATA[name] or ARGS[name] or def_value
    this["get_"..name] = function() return characteristics[name] end
end

-- base values
def_characteristics("body_level", 1)
def_characteristics("soul_level", 1)
def_characteristics("health", 5)
def_characteristics("max_health", 5)
def_characteristics("oxygen", 5)
def_characteristics("max_oxygen", 5)
def_characteristics("mana", 5)
def_characteristics("max_mana", 5)
def_characteristics("agility", 1)
def_characteristics("accuracy", 1)
def_characteristics("heat_preservation", 0)
def_characteristics("heat_reflection", 0)
def_characteristics("crush_damage_protection", 0)
def_characteristics("cutting_damage_protection", 0)
def_characteristics("piercing_damage_protection", 0)

function set_params(param, value)
    characteristics[param] = value
    SAVED_DATA[param] = value
end

function get_characteristics()
    return characteristics
end