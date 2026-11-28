local module = {
    backgrounds = {},
    equipment_slots = {},
    stats = {},
    main = {}
}


module.main = file.read_combined_object("config/newgen/main.json")
module.backgrounds = file.read_combined_list("config/newgen/backgrounds.json")

local stats = file.read_combined_object("config/newgen/stats.json")
local equipment_slots = file.read_combined_object("config/newgen/equipment_slots.json")

for stat, data in pairs(stats) do
    if data.active then
        module.stats[stat] = {
            default = data.default or 0,
            net_type = data["net-type"] or "uint8"
        }
    end
end

for slot, data in pairs(equipment_slots) do
    if data.active then
        table.insert(module.equipment_slots, slot)
    end
end

return module
