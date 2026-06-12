local module = {}
local ores = {}
ores.CHALK_COAL = block.index("newgen:chalk_coal")
ores.DOLOMITE_COAL = block.index("newgen:dolomite_coal")
ores.DOLOMITE_MALACHITE = block.index("newgen:dolomite_malachite_ore")
ores.GYPSUM_COAL = block.index("newgen:gypsum_coal")
ores.LIMESTONE_COAL = block.index("newgen:limestone_coal")
ores.LIMESTONE_MALACHITE = block.index("newgen:dolomite_limestone_ore")
ores.SANDSTONE_COAL = block.index("newgen:sandstone_coal")


function module.find_ores(x, y, z, depth)
    local checked = 0
    while checked < depth do
        module.is_ore(block.get(x, y - checked, z))
        checked = checked + 1
    end
end

function module.is_ore(blockid)
    for _, id in pairs(ores) do
        if id == blockid then
            console.chat(gui.str(block.caption(blockid)) .. " " .. gui.str("found"))
            break
        end
    end
end

return module