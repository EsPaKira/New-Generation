local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Message = api.messages

local VariantMessage = Message.new("newgen", "furnace_variant", { x = "int32", y = "uint8", z = "int32", variant = "uint8" })

local module = {}


if m.side == "server" then
    function module.set_variant(x, y, z, var)
        block.set_variant(x, y, z, var)
        VariantMessage:echo({ x = x, y = y, z = z, variant = var })
    end
else
    VariantMessage:on(function(data)
        if block.get(data.x, data.y, data.z) == -1 then return end -- chunk isn't loaded
        block.set_variant(data.x, data.y, data.z, data.variant)
    end)
end

return module
