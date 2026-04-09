local furnaces = require "furnaces"
local characters = require "characters/characters_main"

local world_data = {}


function world_data.open()
    local path = pack.data_file(PACK_ID, "furnaces_data.bjson")
    if file.exists(path) then
        local bytes = file.read_bytes(path)
        world_data.load(bjson.frombytes(bytes).FURNACES, furnaces)
    end

    path = pack.data_file(PACK_ID, "characters_data.json")
    if file.exists(path) then
        local data = file.read(path)
        world_data.load(json.parse(data), characters)
    else
        -- player_id, character_name, character_id
        -- character_id will be needed for all characters preview 
        characters.unlock_new_character(0, "wayne", 0)
    end
end

function world_data.save()
    local path = pack.data_file(PACK_ID, "furnaces_data.bjson")
    file.write_bytes(path, bjson.tobytes(furnaces))

    path = pack.data_file(PACK_ID, "characters_data.json")
    file.write(path, json.tostring(characters.players, true))
end

function world_data.load(data, module)
    module.open(data)
end

return world_data