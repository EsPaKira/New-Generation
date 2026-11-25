local crafting = require "crafting"
local metadata = require "server/metadata"
local sync = require "furnace_sync"

local INPUT_SLOT, FUEL_SLOT, OUTPUT_SLOT = 0, 1, 2
local UNACTIVE_VARIANT, ACTIVE_VARIANT = 0, 1

local TICK_MS = 50
local TICKS_PER_SECOND = 20
local tick_counter = 0

-- burn-time - ms, recipe.time = s

local module = {}


local function states()
    metadata.data.furnaces = metadata.data.furnaces or {}
    return metadata.data.furnaces
end

local function key(x, y, z)
    return x .. "," .. y .. "," .. z
end

local function furnace_tier(blockid)
    local props = block.properties[blockid]
    local info = props and props["newgen:furnace"]
    return info and info.tier or nil
end

local function fuel_info(itemid)
    if itemid == 0 then return nil end
    local props = item.properties[itemid]
    return props and props["newgen:fuel"] or nil
end

local function pick_recipe(itemid, count, tier)
    if itemid == 0 then return nil, false end

    local best, needs_more_tier = nil, false
    for _, craft in ipairs(crafting.find_all_containing("melting", itemid)) do
        local comp = craft.components[1]
        if comp and comp.id and item.index(comp.id) == itemid and count >= comp.count then
            if craft.tier <= tier then
                if not best or craft.tier > best.tier then
                    best = craft
                end
            else
                needs_more_tier = true
            end
        end
    end

    return best, needs_more_tier
end

local function can_output(invid, result)
    local out_id, out_count = inventory.get(invid, OUTPUT_SLOT)
    if out_id == 0 then return true end

    local result_id = item.index(result.id)
    return out_id == result_id and out_count + result.count <= item.stack_size(result_id)
end

local function put_output(invid, result)
    local result_id = item.index(result.id)
    local out_id, out_count = inventory.get(invid, OUTPUT_SLOT)
    if out_id == 0 then
        inventory.set(invid, OUTPUT_SLOT, result_id, result.count)
    else
        inventory.set_count(invid, OUTPUT_SLOT, out_count + result.count)
    end
end

local function recheck(f, invid, base_tier)
    local effective_tier = math.min(base_tier, f.fuel_tier)
    local input_id, input_count = inventory.get(invid, INPUT_SLOT)
    local recipe, needs_more_tier = pick_recipe(input_id, input_count, effective_tier)

    if recipe then
        if f.recipe_id ~= recipe.recipe_id then
            f.recipe_id = recipe.recipe_id
            f.progress = 0
        end
        f.active = can_output(invid, recipe.results[1])
    elseif needs_more_tier then
        f.active = false
    else
        f.active = false
        f.recipe_id = nil
        f.progress = 0
    end
    f.dirty = false
end

local function get_invid(x, y, z)
    local invid = inventory.get_block(x, y, z)
    return invid ~= 0 and invid or nil
end

local function set_lit(f, lit)
    if f.lit == lit then return end
    f.lit = lit
    sync.set_variant(f.x, f.y, f.z, lit and ACTIVE_VARIANT or UNACTIVE_VARIANT)
end

local function extinguish(f)
    set_lit(f, false)
    states()[key(f.x, f.y, f.z)] = nil
end

local function complete(f, invid, recipe)
    local comp = recipe.components[1]
    local result = recipe.results[1]
    local need = recipe.time * 1000

    local input_id, input_count = inventory.get(invid, INPUT_SLOT)
    if input_id ~= item.index(comp.id) or input_count < comp.count then
        f.active = false
        f.recipe_id = nil
        f.progress = 0
        f.dirty = true
        return
    end

    if not can_output(invid, result) then
        f.active = false
        f.progress = need
        f.dirty = true
        return
    end

    inventory.set_count(invid, INPUT_SLOT, input_count - comp.count)
    put_output(invid, result)
    f.progress = f.progress - need
    f.dirty = true
end

local function tick_furnace(f, check)
    local blockid = block.get(f.x, f.y, f.z)
    if blockid == -1 then return end -- chunk isn't loaded

    local base_tier = furnace_tier(blockid)
    if not base_tier then
        states()[key(f.x, f.y, f.z)] = nil
        return
    end

    local invid = nil

    f.burn_left = f.burn_left - TICK_MS
    if f.burn_left <= 0 then
        local inv = get_invid(f.x, f.y, f.z)
        if not inv then
            states()[key(f.x, f.y, f.z)] = nil
            return
        end

        local overflow = f.burn_left
        local fuel_id, fuel_count = inventory.get(inv, FUEL_SLOT)
        local info = fuel_info(fuel_id)

        if info and fuel_count > 0 then
            inventory.set_count(inv, FUEL_SLOT, fuel_count - 1)
            f.burn_left = info["burn-time"] + overflow
            f.fuel_tier = info.tier
            f.dirty = true
        else
            extinguish(f)
            return
        end
    end

    if check or f.dirty then
        local inv = get_invid(f.x, f.y, f.z)
        if not inv then
            states()[key(f.x, f.y, f.z)] = nil
            return
        end

        recheck(f, inv, base_tier)
    end

    if f.active and f.recipe_id then
        local recipe = crafting.get_recipe(f.recipe_id)
        if not recipe then
            f.active = false
            return
        end

        f.progress = f.progress + TICK_MS
        if f.progress >= recipe.time * 1000 then
            local inv = get_invid(f.x, f.y, f.z)
            if inv then
                complete(f, inv, recipe)
            end
        end
    end
end

-- GLOBALS

function module.ignite(x, y, z)
    local blockid = block.get(x, y, z)
    if blockid == -1 or not furnace_tier(blockid) then return false end

    local invid = inventory.get_block(x, y, z)
    if invid == 0 then return false end

    local k = key(x, y, z)
    if states()[k] then return false end

    local fuel_id, fuel_count = inventory.get(invid, FUEL_SLOT)
    if fuel_count <= 0 or not fuel_info(fuel_id) then return false end

    local f = {
        x = x, y = y, z = z,
        lit = false,
        burn_left = 0,
        fuel_tier = 0,
        progress = 0,
        active = false,
        dirty = true
    }
    states()[k] = f
    set_lit(f, true)

    return true
end

function module.remove(x, y, z)
    states()[key(x, y, z)] = nil
end

function module.is_lit(x, y, z)
    return states()[key(x, y, z)] ~= nil
end

function module.tick()
    tick_counter = tick_counter + 1
    local check = tick_counter == 20
    if check then
        tick_counter = 0
    end

    for _, f in pairs(states()) do
        tick_furnace(f, check)
    end
end

return module
