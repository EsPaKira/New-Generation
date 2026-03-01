local furnaces = require "furnaces"

local world_data = {
    FURNACES = {}
}


function world_data.open()
    local path = pack.data_file(PACK_ID, "furnaces_data.bjson")
    if file.exists(path) then
        local bytes = file.read_bytes(path)
        world_data.FURNACES = bjson.frombytes(bytes)
    end

    world_data.load()
end

function world_data.save()
    local path = pack.data_file(PACK_ID, "furnaces_data.bjson")
    file.write_bytes(path, bjson.tobytes(world_data.FURNACES, true))
end

function world_data.load()
    furnaces.open(world_data.FURNACES)
end

return world_data