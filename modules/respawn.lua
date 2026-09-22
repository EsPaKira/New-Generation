local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Message = api.messages

local RespawnMessage = Message.new("newgen", "respawn", { is_dead = "boolean" })


return RespawnMessage