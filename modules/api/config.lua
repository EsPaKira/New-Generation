local config = {}
config.newgen = file.read_combined_object("config/newgen.json")
config.newgen_backgrounds = file.read_combined_list("config/newgen_backgrounds.json")

function config.get_current_v()
    return config.newgen["newgen-version"]
end

function config.get_backgrounds()
    return config.newgen_backgrounds
end

return config