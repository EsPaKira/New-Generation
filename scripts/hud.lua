local stats = require "client/stats"
local config = require "config"
local survival_ui


function on_hud_open()
    survival_ui = require(config.main["survival-ui"])
    survival_ui.echo()
end