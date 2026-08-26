local module = {
    stats = {}
}


for stat, data in pairs(file.read_combined_object("config/newgen_stats.json")) do
    if data.active then
        module.stats[stat] = {
            default = data.default or 0,
            net_type = data.net_type or "uint8"
        }
    end
end

return module