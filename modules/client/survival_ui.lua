local stats = require "client/stats"
local survival_hud_manager = require "client/survival_hud_manager"
local respawn = require "respawn"

local old_hp = nil
local old_max_hp = nil
local old_oxygen = nil
local old_max_oxygen = nil
local old_hunger = nil
local old_max_hunger = nil
local old_is_dead = false
local death_effect

local module = {}


function module.start()
    death_effect = gfx.posteffects.index("newgen:death")

    input.add_callback("hud.inventory", function()
        --hud.close("newgen:body_tree")
        if hud.is_open("newgen:side_menu") then
            hud.close("newgen:side_menu")
            return
        end
        -- if hud.is_open("newgen:crafts") then
        --     hud.close("newgen:crafts")
        -- end
        if not hud.is_inventory_open() then
            hud.open_permanent("newgen:side_menu")
        end
    end)

    input.add_callback("key:escape", function()
        if hud.is_open("newgen:death_menu") then return true end

        hud.close("newgen:side_menu")
        --hud.close("newgen:body_tree")
    end)
end

function module.update()
    local all_stats = stats.get_all()

    if not all_stats then return end

    if old_hp ~= all_stats.hp or old_max_hp ~= all_stats.max_hp then
        old_hp = all_stats.hp
        old_max_hp = all_stats.max_hp
        survival_hud_manager.set_health(old_hp, old_max_hp)
    end

    if old_oxygen ~= all_stats.oxygen or old_max_oxygen ~= all_stats.max_oxygen then
        old_oxygen = all_stats.oxygen
        old_max_oxygen = all_stats.max_oxygen
        survival_hud_manager.set_oxygen(old_oxygen, old_max_oxygen)
    end

    if old_hunger ~= all_stats.hunger or old_max_hunger ~= all_stats.max_hunger then
        old_hunger = all_stats.hunger
        old_max_hunger = all_stats.max_hunger
        survival_hud_manager.set_hunger(old_hunger, old_max_hunger)
    end

    if all_stats.is_dead ~= old_is_dead then
        old_is_dead = all_stats.is_dead

        if all_stats.is_dead then
            module.open_death_menu()
        end
    end
end

function module.open_survival_hud()
    hud.open_permanent("newgen:survival_ui")
end

function module.close_survival_hud()
    hud.close("newgen:survival_ui")
end

function module.open_death_menu()
    input.set_enabled("hud.inventory", false)
    module.close_survival_hud()
    hud.show_overlay("newgen:death_menu")
    gfx.posteffects.set_effect(death_effect, "death")
    gfx.posteffects.set_intensity(death_effect, 1.0)
end

function module.close_death_menu()
    respawn.on_respawn()
    input.set_enabled("hud.inventory", true)
    module.open_survival_hud()
    hud.close("newgen:death_menu")
    gfx.posteffects.set_intensity(death_effect, 0.0)
end

events.on("newgen:block_open", function()
    hud.open_permanent("newgen:side_menu")
end)

return module