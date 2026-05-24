local gamemodes = require "gamemodes"

function go_back()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    hud.close("newgen:newgen_settings")
    hud.open_inventory()
end

function select(value)
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    gamemodes.set(hud.get_player(), value)
end

function recalculate()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    print("calc")
end

function play_sound()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
end

function on_open()
    document["gamemode_select"].value = gamemodes.get(hud.get_player()).current
end