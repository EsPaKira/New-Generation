local crafting = require "crafting"

local controller = {
    craft_category,
    invid,
    shown_crafts = {}
}

function on_open(craft_category)
    document["crafts_header"].text = craft_category == 0 and gui.str("Crafts") or gui.str("Crafts on " .. craft_category)

    controller.invid = player.get_inventory(hud.get_player())
    controller.craft_category = craft_category
end

function go_back()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    hud.close("newgen:crafts")

    if controller.craft_category == 0 then
        hud.open_inventory()
        hud.open_permanent("newgen:side_menu")
    end
end