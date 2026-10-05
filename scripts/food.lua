local hunger = require "hunger"

function on_use(pid)
    hunger.try_eat(pid)
    return true
end