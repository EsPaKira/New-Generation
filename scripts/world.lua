-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival

local base_util = require "base:util"
local gamemodes = require "gamemodes"
local world_data = require "world_data"
local furnaces = require "furnaces"
local characters = require "characters/characters_main"

local breaking_blocks = {}
local player_loaded = false

local function get_durability(id)
    local durability = block.properties[id]["base:durability"]
    if durability ~= nil then
        return durability
    end
    if block.get_model(id) == "X" then
        return 0.0
    end
    return 5.0
end

local function stop_breaking(target)
    events.emit("newgen:stop_destroy", pid, target)
    target.breaking = false
end

function on_world_open()
    events.on("newgen:gamemodes.set", function(pid, name)
        local entity = entities.get(player.get_entity(pid))
        if entity then
            entity:set_enabled("newgen:health_system", name == "survival")
            entity:set_enabled("newgen:oxygen_system", name == "survival")
        end
    end)
    events.on("newgen:death", function(pos)
        gfx.particles.emit(pos, random.random(40, 70), {
            lifetime = 10,
            lifetime_spread = 2.5,
            spawn_interval = 0.001,
            explosion = {4, 4, 4},
            angle_spread = 0.05,
            velocity = {0, 1, 0},
            acceleration = {0, -11, 0},
            size = {0.5, 0.5, 0.5},
            spawn_shape = "box",
            spawn_spread = {0.5, 0.5, 0.5},
            lighting = true,
            collision = true,
            frames = {
                "particles:blood_0",
                "particles:blood_1"
            }
        })
    end)
    events.on("newgen:player_death", function()
        player_loaded = false
    end)
    rules.create("keep-inventory", false)

    -- open newgen modules
    world_data.open()
end

function on_world_tick() 
    -- tick newgen modules
    furnaces.tick()
end

function on_world_quit()
    -- save newgen data
    world_data.save()
end

local function tick_breaking(pid, tps)
    if player.get_entity(pid) == 0 then
        return -- dead
    end
    local gamemode = gamemodes.get(pid).current
    if gamemode ~= "survival" then
        return
    end
    local target = breaking_blocks[pid]
    if not target then
        target = {breaking=false}
        breaking_blocks[pid] = target
    end

    if input.is_active("player.destroy") then
        local x, y, z = player.get_selected_block(pid)
        local blockid = x and block.get(x, y, z)
        if target.breaking then
            if blockid ~= target.id or 
                x ~= target.x or y ~= target.y or z ~= target.z then
                return stop_breaking(target)
            end
        end
        if blockid == nil or blockid == 0 then
            return
        end
        
        local speed = 1.0 / math.max(get_durability(blockid), 1e-5)
        local power = 1.0
        local invid, slot = player.get_inventory(pid)
        local itemid, _ = inventory.get(invid, slot)
        local tool = item.properties[itemid]["newgen:tool"]
        if tool and tool.type == "breaker" then
            local material = tool.materials[block.material(blockid)]
            if material then
                power = power * material.speed
            end
        end
        speed = speed * power

        if not target.breaking then
            target.breaking = true
            target.id = blockid
            target.x = x
            target.y = y
            target.z = z
            target.tick = 0
            target.progress = 0.0
            target.power = power
            events.emit("newgen:start_destroy", pid, target)
        end

        target.progress = target.progress + (1.0/tps) * speed
        target.power = power
        target.tick = target.tick + 1
        if target.progress >= 1.0 then
            block.destruct(x, y, z, pid)
            if not player.is_infinite_items(pid) then
                inventory.use(invid, slot)
            end
            return stop_breaking(target)
        end
        events.emit("newgen:progress_destroy", pid, target)
    elseif target.wrapper then
        stop_breaking(target)
    end
end

local function player_entity_loaded()
    if player_loaded then return end
    local pentity = entities.get(player.get_entity(hud.get_player()))
    if not pentity then return end

    local c_manager = pentity:require_component("newgen:characteristics_manager")
    c_manager.set_player(hud.get_player(), true)
    characters.update_survival_ui(hud.get_player(), characters.get_choosen_character(hud.get_player()))
    player_loaded = true
end

function on_player_tick(pid, tps)
    player_entity_loaded()
    tick_breaking(pid, tps)
end

function on_block_breaking(id, x, y, z, pid)
    local target = breaking_blocks[pid]
    if not target or not target.breaking then
        tick_breaking(pid, 20)
    end
end

function on_block_broken(id, x, y, z, pid)
    if pid == -1 then
        return
    end
    if gamemodes.get(pid).current ~= "survival" then
        return
    end
    local loot_table = base_util.block_loot(id)
    for _, loot in ipairs(loot_table) do
        base_util.drop({x + 0.5, y + 0.5, z + 0.5}, loot.item, loot.count, loot.data)
    end
end
