local config = {
    data = {}
}
config.newgen = file.read_combined_object("config/newgen.json")
config.newgen_backgrounds = file.read_combined_list("config/newgen_backgrounds.json")

function config.get_current_v()
    return config.newgen["newgen-version"]
end

function config.get_suffocation_damage()
    return config.newgen["suffocation-damage"]
end

function config.get_backgrounds()
    return config.newgen_backgrounds
end

function config.get_all_data()
    config.data.current_version = config.get_current_v()
    return { data = config.data }
end

function config.open(data)
    config.data = data
end

return config