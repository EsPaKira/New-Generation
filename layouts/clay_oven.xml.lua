--local furnaces = require "furnaces"

local controller = {
    invid = nil,
}

events.on("newgen:furnace.remove", function()
    document["fire"].src = "gui/fire"
end)

function on_open(invid)
    controller.invid = invid
    -- if furnaces.contains(controller.invid) then
    --     document["fire"].src = "gui/fire_active"
    -- else
    --     document["fire"].src = "gui/fire"
    -- end
end
