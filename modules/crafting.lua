local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Module = api.utils.classes.module
local Message = api.messages

local CraftRequest = Message.new("newgen", "craft", {})
local crafts = {}

local self = Module()


function self.shared.load_and_update()
    local all_crafts = file.list_all_res("crafts")
    for _, craft in ipairs(all_crafts) do
        -- craft = PACK_ID:crafts/file_name.json

        local craft_name = craft:match("([^/]+)$"):match("^(.*)%.") -- get file_name
        if not crafts[craft_name] then
            crafts[craft_name] = file.read_combined_list(craft:match("([^:]+)$"))
        end
    end
end

return self:build()