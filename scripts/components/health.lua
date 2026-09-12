-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival
local stats = entity:require_component("newgen:stats")
-- local hunger_system = entity:get_component("newgen:hunger_system")

local health_regen_timer = 0
local in_battle_timer = 0
local hunger_timer = 0
local max_fall_y = nil


function set_health(value)
    local health = stats:get_hp()
    local max_health = stats:get_max_hp()

    health = math.min(math.max(0, health - value), max_health)
    stats.set_stat("hp", health)

    if health == 0 then
        die()
    end
end

function die()
    local tsf = entity.transform

    local pid = entity:get_player()
    if pid == -1 then
        local loot = entity:get_component("newgen:loot")
        if loot then
            loot.drop_loot()
        end
        -- entity:despawn()
        return
    end

    -- if not rules.get("keep-inventory") then
    --     DI.drop_inventory(player.get_inventory(pid), entity.transform:get_pos(), 8)
    -- end
    -- entity:despawn()
    -- player.set_entity(pid, 0)
end

function heal(points)
    if points == 0 then return end
    set_health(-points)
end

local function calculate_damage(points, type)
    -- if type == "falling" or type == "suffocation" or type == "hunger" then return points end
    -- local protection = c_manager["get_" .. type .. "_damage_protection"]()
    -- return math.round(math.max(0, (points - c_manager:get_absolute_damage_protection()) * (1 - protection)))
    return points
end

function damage(points, type)
    if points == 0 then return end

    local pid = entity:get_player()
    if pid and player.is_instant_destruction(pid) then
        return
    end

    in_battle_timer = 10

    local end_damage = calculate_damage(points, type)

    set_health(end_damage)
end

-- local function should_heal()
--     local hunger, max_hunger = hunger_system.get_hunger()

--     if hunger < max_hunger then return true end
--     return false
-- end

-- function on_update(tps)
--     if health_regen_timer >= 1 and in_battle_timer <= 0 then
--         if hunger_system then -- will be moved into effect system in the future
--             if not should_heal() then
--                 health_regen_timer = 0
--                 damage(1, "hunger")
--                 return
--             end
--         end

--         heal(1)
--         health_regen_timer = 0
--     end

--     health_regen_timer = health_regen_timer + 1 / tps
--     in_battle_timer = in_battle_timer - 1 / tps
-- end

function on_update(tps)
    local y = entity.transform:get_pos()[2]
    if max_fall_y == nil or y > max_fall_y then
        max_fall_y = y
    end
end

function on_grounded()
    local y = entity.transform:get_pos()[2]
    local height = (max_fall_y or y) - y
    max_fall_y = nil

    if height <= 0 then return end

    local dmg = math.max(0, math.floor((height - 3) * 2))
    damage(dmg, "falling")
end