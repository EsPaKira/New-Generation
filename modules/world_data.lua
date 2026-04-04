local furnaces = require "furnaces"
local ST = require "skill_trees"

local world_data = {
    FURNACES = {},
    SKILL_TREES = {}
}


function world_data.open()
    local path = pack.data_file(PACK_ID, "furnaces_data.bjson")
    if file.exists(path) then
        local bytes = file.read_bytes(path)
        world_data.FURNACES = bjson.frombytes(bytes).FURNACES
    end

    path = pack.data_file(PACK_ID, "skill_trees_data.bjson")
    if file.exists(path) then
        local bytes = file.read_bytes(path)
        world_data.SKILL_TREES = bjson.frombytes(bytes).characters
    end

    world_data.load()
end

function world_data.save()
    local path = pack.data_file(PACK_ID, "furnaces_data.bjson")
    file.write_bytes(path, bjson.tobytes(furnaces))

    path = pack.data_file(PACK_ID, "skill_trees_data.bjson")
    file.write_bytes(path, bjson.tobytes(ST))
end

function world_data.load()
    furnaces.open(world_data.FURNACES)
    ST.open(world_data.SKILL_TREES)
end

return world_data