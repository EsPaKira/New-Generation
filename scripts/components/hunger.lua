local m = _G["$Multiplayer"]
if m.side == "client" then return end

local stats = entity:require_component("newgen:stats")

local hunger_progress = 0


local function set_hunger(value)
    if value == 0 then return end
    if player.is_instant_destruction(entity:get_player()) then return end

    local max_hunger = stats:get_max_hunger()

    stats.set_stat("hunger", math.min(math.max(0, value), max_hunger))
end

function on_update(tps)
    if hunger_progress >= 120 then
        hunger_progress = 0
        set_hunger(stats:get_hunger() + 1)
    end
    hunger_progress = hunger_progress + 1 / tps
end

function eat(saturation)
    set_hunger(stats:get_hunger() - saturation)
end

events.on("newgen:heal", function(pid)
    if pid ~= entity:get_player() then return end
    set_hunger(stats:get_hunger() + 1)
end)