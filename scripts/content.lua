local m = _G["$Multiplayer"]

function on_scripts_loading()
    require "rules"

    if m.side == "server" then
        require "server/console"
    elseif m.side == "client" then
        return
    end
end