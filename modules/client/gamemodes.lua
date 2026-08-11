local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2])).server
local Message = import "net/protocol/message"


local GamemodeMsg = Message.new("newgen", "gamemode.set", {
    name = "boolean"
})

local function set(pid)
    print(pid)
end

GamemodeMsg:on(function(data)
    if not data.name then return end
    set(hud.get_player())
end)