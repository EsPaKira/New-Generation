local furnaces = require "furnaces"
local characters = require "characters/main"
local api = require "api/api_main"
local config = require "api/config"
local spawners = require "spawners"

local world_data = {}


function world_data.open()
    local path = pack.data_file(PACK_ID, "furnaces_data.bjson")
    if file.exists(path) then
        local bytes = file.read_bytes(path)
        world_data.load(bjson.frombytes(bytes).FURNACES, furnaces)
    end

    path = pack.data_file(PACK_ID, "config.json")
    if file.exists(path) then
        local data = file.read(path)
        world_data.load(json.parse(data).data, config)
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

    path = pack.data_file(PACK_ID, "api.json")
    if file.exists(path) then
        local data = file.read(path)
        world_data.load(json.parse(data), api)
    end

    path = pack.data_file(PACK_ID, "spawners.json")
    if file.exists(path) then
        local data = file.read(path)
        world_data.load(json.parse(data).data, spawners)
    end
end

function world_data.save()
    local path = pack.data_file(PACK_ID, "furnaces_data.bjson")
    file.write_bytes(path, bjson.tobytes(furnaces.get_all_data()))

    path = pack.data_file(PACK_ID, "characters_data.json")
    file.write(path, json.tostring(characters.players, true))

    path = pack.data_file(PACK_ID, "api.json")
    file.write(path, json.tostring(api.ui, true))

    path = pack.data_file(PACK_ID, "config.json")
    file.write(path, json.tostring(config.get_all_data(), true))

    path = pack.data_file(PACK_ID, "spawners.json")
    file.write(path, json.tostring(spawners.get_all_data(), true))
end

function world_data.load(data, module)
    module.open(data)
end

return world_data