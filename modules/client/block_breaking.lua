local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2]))[m.side]
local BreakingEvent = require "breaking_events"

local current_block = nil
local instant = nil

local module = {}


local function is_current_block(x, y, z)
    return x ~= nil and x == current_block.x and y == current_block.y and z == current_block.z
end

local function stop_instant()
    if instant then
        if instant.active then
            instant:interrupt()
        else
            instant.abandoned = true
        end
        instant = nil
    end
    current_block = nil
end

function module.start_breaking(x, y, z, pid)
    if player.is_instant_destruction(pid) then return end

    local blockid = block.get(x, y, z)
    if blockid == -1 then return end

    if current_block and is_current_block(x, y, z) then return end

    stop_instant()

    current_block = { x = x, y = y, z = z }
    local pos = {x, y, z}
    instant = BreakingEvent:start({ pos = pos, blockid = blockid })
end

function module.block_broken()
    stop_instant()
end

function module.player_tick(pid)
    if not current_block then return end

    local x, y, z = player.get_selected_block(pid)
    local still_breaking = is_current_block(x, y, z) and input.is_active("player.destroy")

    if not still_breaking then
        stop_instant()
    end
end

return module