local module = {}


module.background = file.read(pack.shared_file(PACK_ID, "background.txt"))

function module.save_background(value)
    module.background = value
    file.write(pack.shared_file(PACK_ID, "background.txt"), value)
end

return module
