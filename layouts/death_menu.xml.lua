local survival_ui = require "client/survival_ui"


function on_respawn()
    survival_ui.close_death_menu()
end