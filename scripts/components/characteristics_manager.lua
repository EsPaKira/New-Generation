local characters = require "characters/characters_main"
local characteristics = {}

local function def_characteristics(name, def_value)
    characteristics[name] = SAVED_DATA[name] or ARGS[name] or def_value
    this["get_"..name] = function() return characteristics[name] or SAVED_DATA[name] or ARGS[name] or def_value end
end

-- base values
def_characteristics("body_level", 1)
def_characteristics("soul_level", 1)
def_characteristics("health", 5)
def_characteristics("max_health", 5)
def_characteristics("oxygen", 5)
def_characteristics("max_oxygen", 5)
def_characteristics("archium", 0)
def_characteristics("max_archium", 0)
def_characteristics("agility", 1)
def_characteristics("accuracy", 1)
def_characteristics("heat_preservation", 0)
def_characteristics("heat_reflection", 0)
def_characteristics("crush_damage_protection", 0)
def_characteristics("slashing_damage_protection", 0)
def_characteristics("piercing_damage_protection", 0)

def_characteristics("is_player", false)

function set_params(param, value)
    characteristics[param] = value
    SAVED_DATA[param] = value
end

function get_characteristics()
    return characteristics
end

function set_player(pid, value)
    set_params("is_player", value)
    if value then 
        characters.set_choosen_character(pid, ARGS.name)
        set_player_characteristics(pid, ARGS.name)
    end
end

function is_player()
    local pid = entity:get_player()
    if pid ~= -1 then
        set_player_characteristics(pid, ARGS.name)
        return true, ARGS.name
    end
    return characteristics["is_player"], ARGS.name
end

function set_player_characteristics(pid, character_name)
    local stats = characters.get_group(pid, character_name, "stats")
    for key, value in pairs(stats) do
        set_params(key, value)
    end
end