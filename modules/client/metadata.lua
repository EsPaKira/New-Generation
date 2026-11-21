local module = {}


if file.exists("config:newgen/background.txt") then
    module.background = file.read(pack.shared_file(PACK_ID, "background.txt"))
else
    module.background = "gui/space"
end

function module.save_background(value)
    module.background = value
    file.write(pack.shared_file(PACK_ID, "background.txt"), value)
end

return module
