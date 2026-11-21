local config = require "config"
local metadata = require "client/metadata"


function go_back()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    hud.close("newgen:newgen_settings")
    hud.open_inventory()
end

function select_bg(value)
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    metadata.save_background(value)
    load_bg()
end

function play_sound()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
end

function load_variants_bg()
    local bgs = config.backgrounds

    local options = {}
    for _, bg in ipairs(bgs) do
        local option = {
            value = bg,
            text = gui.str(bg)
        }
        table.insert(options, option)
    end
    document["bg_select"].options = options
end

function load_bg()
    local bg = metadata.background
    document["bg_select"].value = bg
    document["background"].src = bg
end

function on_open()
    local current_gm = player.is_instant_destruction(hud.get_player()) and "creative" or "survival"

    document["current_gamemode"].text = gui.str("Current gamemode") .. ": " .. gui.str(current_gm)
    load_variants_bg()
    load_bg()
end
