local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]

local InfiniteItems = api.rules.define_if_absent("infinite-items", { default = true, level = "player" })
local KeepInventory = api.rules.define_if_absent("keep-inventory", { default = true, level = "world" })