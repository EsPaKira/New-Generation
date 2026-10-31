-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival
local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local Module = api.utils.classes.module
local Message = api.messages

local base_util = require "base:util"

local CraftRequest = Message.new("newgen", "craft", { recipe_id = "string" })
local crafts_by_category = {}
local crafts_all = {}

local self = Module()

-- SHARED

local function build_consumption_plan(pinvid, craft)
    local plan = {}
    local remaining_by_slot = {}
    local itemid_by_slot = {}
    local inventory_size = inventory.size(pinvid)

    for slot = 0, inventory_size - 1 do
        local itemid, count = inventory.get(pinvid, slot)
        itemid_by_slot[slot] = itemid
        remaining_by_slot[slot] = count or 0
    end

    for i, component in ipairs(craft.components) do
        local needed = component.count

        for slot = 0, inventory_size - 1 do
            if needed <= 0 then
                break
            end

            local itemid = itemid_by_slot[slot]
            local matches
            if component.id then
                matches = itemid == item.index(component.id)
            else
                matches = item.has_tag(itemid, component.tag)
            end

            if matches and remaining_by_slot[slot] > 0 then
                local take = math.min(needed, remaining_by_slot[slot])
                remaining_by_slot[slot] = remaining_by_slot[slot] - take
                plan[slot] = (plan[slot] or 0) + take
                needed = needed - take
            end
        end

        if needed > 0 then
            return nil
        end
    end

    return plan
end

function self.shared.load()
    local all_crafts = file.list_all_res("crafts")
    for _, categories in ipairs(all_crafts) do
        local category = categories:match("/(.+)")
        local group = categories:match(":(.+)")
        crafts_by_category[category] = crafts_by_category[category] or {}

        for _, craft in ipairs(file.list_all_res(group)) do
            local craft_name = craft:match("/([^/.]+)%.json$")
            if not crafts_by_category[category][craft_name] then
                local craft_data = file.read_combined_object(craft:match(":(.+)"))
                crafts_by_category[category][craft_name] = craft_data
                crafts_all[category .. ":" .. craft_name] = craft_data
            end
        end
    end
end

function self.shared.find_all_containing(category, itemid)
    local found = {}

    if not crafts_by_category[category] then return found end

    for _, craft in pairs(crafts_by_category[category]) do
        for _, comp in ipairs(craft.components or {}) do
            local matches = false

            if comp.id then
                matches = itemid == item.index(comp.id)
            elseif comp.tag then
                matches = itemid ~= nil and item.has_tag(itemid, comp.tag)
            end

            if matches then
                table.insert(found, craft)
                break
            end
        end
    end

    return found
end

-- SERVER

local function drop_overflow(pid, itemid, count)
    local drop_pos = { player.get_pos(pid) }
    base_util.drop(drop_pos, itemid, count)
end

function self.server.craft(pid, craft_name)
    local craft = crafts_all[craft_name]
    if not craft then return end

    local pinvid = player.get_inventory(pid)
    local consumption_plan = build_consumption_plan(pinvid, craft)
    if not consumption_plan then return end

    for slot, count in pairs(consumption_plan) do
        inventory.decrement(pinvid, slot, count)
    end

    for i, result in ipairs(craft.results) do
        local itemid = result.id
        local overflow = inventory.add(pinvid, itemid, result.count)

        if overflow > 0 then
            drop_overflow(pid, itemid, overflow)
        end
    end
end

CraftRequest:on(function(client, data)
    self.craft(client.player.pid, data.recipe_id)
end)

-- CLIENT

function self.client.find_all_results(itemid)
    local found = {}
    itemid = item.name(itemid)

    for category, crafts in pairs(crafts_by_category) do
        for _, craft in pairs(crafts) do
            for _, results in ipairs(craft.results or {}) do
                if results.id == itemid then
                    table.insert(found, {category, craft})
                    break
                end
            end
        end
    end

    return found
end

function self.client.get_component_count(pinvid, component)
    local total = 0

    for slot = 0, inventory.size(pinvid) - 1 do
        local itemid, count = inventory.get(pinvid, slot)

        if itemid ~= 0 and count > 0 then
            local matches

            if component.id then
                matches = itemid == item.index(component.id)
            else
                matches = item.has_tag(itemid, component.tag)
            end

            if matches then
                total = total + count
            end
        end
    end

    return total
end

function self.client.is_enough(recipe_id, pinvid)
    local craft = crafts_all[recipe_id]
    if not craft then return false end

    return build_consumption_plan(pinvid, craft) ~= nil
end

function self.client.try_craft(craft_name)
    CraftRequest:send({ recipe_id = craft_name })
end

return self:build()