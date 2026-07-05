function on_random_update(x, y, z)
    local current_weather = gfx.weather.get_current()
    local hum = block.get_field(x, y, z, "humidity") or 0

    if current_weather == "rain" or current_weather == "thunder" then
        hum = math.min(hum + 1, 4)
        block.set_field(x, y, z, "humidity", hum)
    else
        hum = math.max(hum - 1, 0)
        block.set_field(x, y, z, "humidity", hum)
    end

    if hum == 0 then
        block.set_variant(x, y, z, 0)
    else
        block.set_variant(x, y, z, 1)
    end
end