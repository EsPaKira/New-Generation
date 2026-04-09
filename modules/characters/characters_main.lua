local survival_ui = require "survival_ui"

local characters = {
    players = {}
}
-- players = {
--  pid1 = {
--      choosen_character = character_name or nil,
--      character1 = data{},
--      character2 = data{},...
--  },
--  pid2 = ...
--}

function characters.unlock_new_character(pid, character_name, cid)
    local player_characters = characters.get_player_data(pid)
    local character_data = file.read_combined_object("characters/" .. character_name .. ".json")
    player_characters[character_name] = {
        character_id = cid,
        character_full_name = character_data["full-name"],
        entity_id = nil,
        stats = character_data["stats"],
        equipment = {},
        skills = {}
    }
end
-- below - character data structure
-- group     > field      > value
-- equipment > slot       > name
-- stats     > stat_name  > value
-- skills    > skill_name > level
function characters.set_field(pid, character_name, group, field, value)
    local character = characters.get_character(pid, character_name)
    if not character then return end
    character[group][field] = value
    if characters.get_choosen_character(pid) == character_name then
        local pentity = entities.get(player.get_entity(pid))
        if not pentity then return end
        local c_manager = pentity:require_component("newgen:characteristics_manager")
        c_manager.set_params(field, value)
    end
end

function characters.get_field(pid, character_name, group, field)
    local character = characters.get_character(pid, character_name)
    if not character then return nil end

    return character[group][field]
end

function characters.get_group(pid, character_name, group)
    local character = characters.get_character(pid, character_name)
    if not character then return nil end

    return character[group]
end

function characters.set_choosen_character(pid, character_name)
    local player_data = characters.get_player_data(pid)
    player_data.choosen_character = character_name
end

function characters.get_choosen_character(pid)
    local player_data = characters.get_player_data(pid)
    return player_data.choosen_character
end

function characters.get_player_data(pid)
    if characters.players[tostring(pid)] == nil then
        characters.players[tostring(pid)] = {
            choosen_character = nil
        }
    end
    return characters.players[tostring(pid)]
end

function characters.get_character(pid, character_name)
    local player_data = characters.get_player_data(tostring(pid))
    return player_data[character_name]
end

function characters.update_survival_ui(pid, character_name)
    local health = characters.get_field(pid, character_name, "stats", "health")
    local max_health = characters.get_field(pid, character_name, "stats", "max_health")
    survival_ui.set_health(health, max_health)

    local oxygen = characters.get_field(pid, character_name, "stats", "oxygen")
    local max_oxygen = characters.get_field(pid, character_name, "stats", "max_oxygen")
    survival_ui.set_oxygen(oxygen, max_oxygen)
end

function characters.open(data)
    characters.players = data
end

return characters