local module = {
    data = {
        players = {}
    }
}


function module.load()
    for _, path in ipairs(file.list("world:data/newgen")) do
        local name = file.stem(path)
        local data = file.read(path)
        module.data[name] = json.parse(data)
    end
end

function module.save()
    for name, data in pairs(module.data) do
        local path = pack.data_file(PACK_ID, name .. ".json")
        file.write(path, json.tostring(data, true))
    end
end

return module