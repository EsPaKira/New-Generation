local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Module = api.utils.classes.module
local Message = api.messages

local EatMessage = Message.new("newgen", "eat", {})


local self = Module()

-- SERVER

function self.server.eat(client)
    local pid = client.player.pid
    local pentity = entities.get(player.get_entity(pid))
    if not pentity then return end

    local pinvid, slot = player.get_inventory(pid)
    local itemid, _ = inventory.get(pinvid, slot)
    local item_props = item.properties[itemid]["newgen:food"]

    if not item_props
    or not item_props["saturation"]
    or type(item_props["saturation"]) ~= "number" then return end

    local hunger_component = pentity:get_component("newgen:hunger")
    if not hunger_component then return end

    hunger_component.eat(item_props["saturation"])

    if player.is_infinite_items(pid) then return end

    inventory.decrement(pinvid, slot, 1)
end

EatMessage:on(function(client)
    self.eat(client)
end)

-- CLIENT

function self.client.try_eat(pid)
    local pinvid, slot = player.get_inventory(pid)
    local itemid, _ = inventory.get(pinvid, slot)
    local item_props = item.properties[itemid]["newgen:food"]

    if not item_props
    or not item_props["saturation"]
    or type(item_props["saturation"]) ~= "number" then return end

    EatMessage:send({})
end


return self:build()