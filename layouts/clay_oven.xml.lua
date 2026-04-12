local furnaces = require "furnaces"

local controller = {
    invid = nil,
}

events.on("newgen:furnace.remove", function()
    document["fire"].src = "gui/fire"
end)

events.on("newgen:furnace.update", function(t, m, _, invid)
    if invid ~= controller.invid then return end
    document["t"].text = "t: " .. t or 0
    document["m"].text = "m: " .. m or 0
end)

function on_open(invid)
    controller.invid = invid
    if furnaces.contains(controller.invid) then
        document["fire"].src = "gui/fire_active"
    else
        document["fire"].src = "gui/fire"
        document["t"].text = ""
        document["m"].text = ""
    end
end