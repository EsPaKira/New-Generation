local weather = {
    started = false,
    timer = 0
}

local ALL_PRESETS = {
    clear = 0.4,
    cloudy = 0.15,
    fog = 0.10,
    rain = 0.15,
    snow = 0.10,
    thunder = 0.10
}


function weather.get_data(name)
    -- maybe not good solution
    local path = "res:presets/weather/" .. name .. ".json"
    if file.exists(path) then
        local data = file.read(path)
        return json.parse(data)
    end
    return nil
end

function weather.set(name, time)
    local data = weather.get_data(name)
    if data then
        gfx.weather.change(data, time, name)
    end
end

function weather.tick()
    if not weather.started then return end
    weather.timer = weather.timer + 1/20
    local rand = random.random(20, 50)
    if weather.timer >= random.random(rand + 80, rand + 180) then
        weather.set(weather.select_random(), rand)
        weather.timer = 0
    end
end

function weather.select_random()
    local total_probability = 0
    local weather_pairs = {}

    for name, probability in pairs(ALL_PRESETS) do
        total_probability = total_probability + probability
        table.insert(weather_pairs, {name, total_probability})
    end

    local rand = random.random()

    for _, pair in ipairs(weather_pairs) do
        if rand <= pair[2] then
            return pair[1]
        end
    end
end

function weather.start()
    weather.started = true
end

return weather