local m = _G["$Multiplayer"]

function on_scripts_loading()
    require "rules"
    require "breaking_events"

    if m.side == "server" then
        require "server/console"
    else
        return
    end
end