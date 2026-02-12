function open_player_menu()
    hud.show_overlay("newgen:player_menu")
end

function open_crafting_menu()
    hud.close("newgen:player_button")
    hud.show_overlay("newgen:crafts", false)
end