local config = require "config"
local survival_ui

local pid


function on_hud_open()
    survival_ui = require(config.main["survival-ui"])
    survival_ui.open()
    survival_ui.update()

    pid = hud.get_player()
    events.emit("newgen:hud_loaded", pid)
end

function on_hud_render()
    if player.is_instant_destruction(pid) then
        survival_ui.close_survival_hud()
    else
        survival_ui.open_survival_hud()
    end
    survival_ui.update()
end