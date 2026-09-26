local config = require "config"
local survival_ui

local pid
local creative


function on_hud_open()
    survival_ui = require(config.main["survival-ui"])
    survival_ui.start()
    pid = hud.get_player()
    events.emit("newgen:hud_loaded", pid)

    creative = player.is_instant_destruction(pid)

    if not creative then
        survival_ui.open_survival_hud()
        survival_ui.update()
    end
end

function on_hud_render()
    local is_creative = player.is_instant_destruction(pid)

    if is_creative ~= creative then
        creative = is_creative

        if creative then
            survival_ui.close_survival_hud()
            return
        else
            if not hud.is_open(config.main["death-menu"]) then
                survival_ui.open_survival_hud()
            end
        end
    end

    survival_ui.update()
end