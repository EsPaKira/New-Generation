local characters = {
    players = {}
}
-- players = {
--  pid1 = {
--      character1 = data{},
--      character2 = data{},...
--  },
--  pid2 = ...
--}

function characters.unlock_new_character(pid, character_name)
    local player_characters = characters.get_player_data(pid)
    player_characters[character_name] = {
        stats = {},
        equipment = {},
        skills = {}
    }
end
-- group     > field      > value
-- equipment > slot       > name
-- stats     > stat_name  > value
-- skills    > skill_name > level
function characters.set_field(pid, character_name, group, field, value)
    local character = characters.get_character(pid, character_name)
    if not character then return end

    character[group][field] = value
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

function characters.get_player_data(pid)
    if characters.players[pid] == nil then
        characters.players[pid] = {}
    end
    return characters.players[pid]
end

function characters.get_character(pid, character_name)
    local player_data = characters.get_player_data(pid)
    return player_data[character_name]
end

return characters