local gamemodes = require "gamemodes"
local api = require "api/api_main"
local config = require "api/config"
local characters = require "characters/main"
local recalculate = require "characters/recalculate"

function go_back()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    hud.close("newgen:newgen_settings")
    hud.open_inventory()
end

function select(value)
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    gamemodes.set(hud.get_player(), value)
end

function select_bg(value)
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    api.set_background(value)
    load_bg()
end

function recalculate_button()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    recalculate.recalculate(characters.players)
end

function play_sound()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
end

function load_variants_bg()
    local bgs = config.get_backgrounds()
    document["bg_select"]:clear()

    local options = {}
    for _, bg in ipairs(bgs) do
        local option = {
            value = bg,
            text = gui.str(bg)
        }
        table.insert(options, option)
    end
    document["bg_select"].options = options -- document["bg_select"]:add(<option />) not supported
end

function load_bg()
    local bg = api.get_background()
    document["bg_select"].value = bg -- doesn't work
    document["background"].src = bg
end

function on_open()
    document["gamemode_select"].value = gamemodes.get(hud.get_player()).current
    load_variants_bg()
    load_bg()
end