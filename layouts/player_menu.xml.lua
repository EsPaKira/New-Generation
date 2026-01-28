local gamemodes = require "gamemodes"

function go_back()
    hud.close("newgen_survival:player_menu")
    close_c_panel()
    close_equipment_menu()
    hud.open_inventory()
end

function open_c_panel()
    if document["c_panel"].visible == true then
        document["c_panel"].visible = false
        document["close_c_panel"].visible = false
        return
    end

    document["c_panel"].visible = true
    document["close_c_panel"].visible = true
    local c_manager = gamemodes.get_characteristics_manager(hud.get_player())
    local characteristics = c_manager.get_characteristics()
    table.map(characteristics, function(i, value)
        if i == "health" or i == "oxygen" or i == "mana" then
            return
        end
        document[i].text = tostring(value)
    end)
end

function close_c_panel()
    document["c_panel"].visible = false
    document["close_c_panel"].visible = false
end

local choosen_slot = nil
function open_equipment_menu(slot)
    choose_equipment_slot(slot)
    close_c_panel()
    document["equipment_menu"].visible = true
end

function close_equipment_menu()
    document["equipment_menu"].visible = false
end

function choose_equipment_slot(new_slot)
    if new_slot == choosen_slot then
        return
    end
    if new_slot ~= nil then
        document[new_slot .. "_info"].color = {100, 100, 100, 100}
    end
    if choosen_slot ~= nil then
        document[choosen_slot .. "_info"].color = {255, 255, 255, 0}
        document[choosen_slot .. "_info"].hoverColor = {100, 100, 100, 100}
    end
    choosen_slot = new_slot
end

function on_open()
    close_c_panel()
    close_equipment_menu()
end