local m = _G["$Multiplayer"]

function on_scripts_loading()
    require "rules"
    require "breaking_events"
    require "config"

    if m.side == "server" then
        require "server/console"
        require "server/stats"
    else
        return
    end
end