local version_manager = {}

function version_manager.get_current()
    local newgen_config = file.read_combined_object("config/newgen.json")
    return newgen_config["newgen-version"]
end

return version_manager