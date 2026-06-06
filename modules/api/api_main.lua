local api = {
    ui = {
        current_background = "gui/space"
    }
}


function api.open(data)
    api.ui = data

    api.change_background(data.current_background)
end

function api.change_background(new_bg)
    api.ui.current_background = new_bg
end

function api.get_background()
    return api.ui.current_background
end

function api.set_background(value)
    api.ui.current_background = value
end

return api