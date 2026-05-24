function open_player_menu()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    hud.show_overlay("newgen:player_menu")
end

function open_crafting_menu()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    hud.close("newgen:player_button")
    hud.show_overlay("newgen:crafts", false)
end

function open_settings_menu()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    hud.show_overlay("newgen:newgen_settings")
end