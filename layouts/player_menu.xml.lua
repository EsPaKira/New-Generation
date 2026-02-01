local gamemodes = require "gamemodes"
local e_search = require "equipment_search"

local controller = {
    equipment = nil,
    choosen_slot = nil,
    choosen_equipment = nil
}

function go_back()
    hud.close("newgen_survival:player_menu")
    close_c_panel()
    close_equipment_menu()
    hud.open_inventory()
end

function open_c_panel()
    if document["c_panel"].visible == true then
        close_c_panel()
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

function open_equipment_menu(slot)
    choose_equipment_slot(slot)
    close_c_panel()
    document["equipment_menu"].visible = true
end

function close_equipment_menu()
    document["equipment_menu"].visible = false
    document["equipment_list"].visible = false
end

function choose_equipment_slot(new_slot)
    if new_slot == controller.choosen_slot then
        open_equipment_list()
        return
    end
    if new_slot ~= nil then
        document[new_slot .. "_info"].color = {100, 100, 100, 100}
    end
    if controller.choosen_slot ~= nil then
        document[controller.choosen_slot .. "_info"].color = {255, 255, 255, 0}
        document[controller.choosen_slot .. "_info"].hoverColor = {100, 100, 100, 100}
    end
    controller.choosen_slot = new_slot
    open_equipment_list()
end

function choose_equipment_xml(new_equipment)
    if new_equipment == controller.choosen_equipment then
        return
    end
    if new_equipment ~= nil then
        document["equipment_cell_" .. new_equipment].color = {100, 100, 100, 100}
    end
    if controller.choosen_equipment ~= nil then
        document["equipment_cell_" .. controller.choosen_equipment].color = {255, 255, 255, 0}
        document["equipment_cell_" .. controller.choosen_equipment].hoverColor = {100, 100, 100, 100}
    end
    controller.choosen_equipment = new_equipment
end

function open_equipment_list()
    document["equipment_list"]:clear()
    document["equipment_list"].visible = true
    show_equipped_item()
    document["choosen_item_info"]:clear()

    controller.equipment = e_search.search_equipment_by_tag(player.get_inventory(hud.get_player()), controller.choosen_slot)
    local e_cols = math.ceil(#controller.equipment / 5)

    local index = 0
    for col = 0, e_cols - 1 do
        for row = 0, 4 do
            index = index + 1
            if index > #controller.equipment then
                return
            end
            document["equipment_list"]:add(gui.template("equipment_cell", {
                x = 3 + row * 111,
                y = 3 + col * 111,
                src = item.icon(controller.equipment[index]) or "blocks:notfound",
                index = index
            }), controller)
        end
    end
end

function show_equipped_item()
    document["equipped_item_info"]:clear()
    local e_system = e_search.get_equipment_system(hud.get_player())
    if e_system.get_item_by_slot(controller.choosen_slot) == 0 then
        document["equipped_item_info"]:add(gui.template("no_equipment_info"))
        return
    end
    document["equipped_item_info"]:add(gui.template("equipment_info", {
        src = item.icon(e_system.get_item_by_slot(controller.choosen_slot)),
        heat_p = e_system.get_characteristic_by_slot(controller.choosen_slot, "heat_preservation"),
        heat_r = e_system.get_characteristic_by_slot(controller.choosen_slot, "heat_reflection"),
        crush_d_p = e_system.get_characteristic_by_slot(controller.choosen_slot, "crush_damage_protection"),
        slashing_d_p = e_system.get_characteristic_by_slot(controller.choosen_slot, "slashing_damage_protection"),
        piercing_d_p = e_system.get_characteristic_by_slot(controller.choosen_slot, "piercing_damage_protection")
    }))
end

function on_open()
    controller.choosen_equipment = nil
    close_c_panel()
    close_equipment_menu()
end

function equipment_button(value)
    local e_system = e_search.get_equipment_system(hud.get_player())
    if value == "equip" then
        if e_system.get_item_by_slot(controller.choosen_slot) ~= 0 then
            local equipped_item = e_system.get_item_by_slot(controller.choosen_slot)
            local slot = inventory.find_by_item(player.get_inventory(hud.get_player()), controller.equipment[controller.choosen_equipment])
            inventory.set(player.get_inventory(hud.get_player()), slot, equipped_item, 1)
            e_system.set_equipment(controller.choosen_slot, controller.equipment[controller.choosen_equipment])
            controller.choosen_equipment = nil
            open_equipment_list()
        else
            local slot = inventory.find_by_item(player.get_inventory(hud.get_player()), controller.equipment[controller.choosen_equipment])
            inventory.set(player.get_inventory(hud.get_player()), slot, 0, 1)
            e_system.set_equipment(controller.choosen_slot, controller.equipment[controller.choosen_equipment])
            controller.choosen_equipment = nil
            open_equipment_list()
        end
    else
        if e_system.get_item_by_slot(controller.choosen_slot) ~= nil and e_system.get_item_by_slot(controller.choosen_slot) ~= 0 then
            local slot = inventory.find_by_item(player.get_inventory(hud.get_player()), 0)
            if slot == nil then
                document["cannot_remove_item"].visible = true
                return
            end

            local equipped_item = e_system.get_item_by_slot(controller.choosen_slot)
            inventory.set(player.get_inventory(hud.get_player()), slot, equipped_item, 1)
            e_system.remove_equipment(controller.choosen_slot)
            controller.choosen_equipment = nil
            open_equipment_list()
        end
    end
end

function hide_error_info()
    document["cannot_remove_item"].visible = false
end

function controller:choose_equipment(id)
    document["choosen_item_info"]:clear()
    choose_equipment_xml(id)
    local e_system = e_search.get_equipment_system(hud.get_player())

    document["choosen_item_info"]:add(gui.template("choosen_equipment_info", {
        src = item.icon(controller.equipment[id]),
        heat_p = e_search.get_equipment_characteristics(controller.equipment[id], controller.choosen_slot, hud.get_player(), "heat_preservation"),
        heat_r = e_search.get_equipment_characteristics(controller.equipment[id], controller.choosen_slot, hud.get_player(), "heat_reflection"),
        crush_d_p = e_search.get_equipment_characteristics(controller.equipment[id], controller.choosen_slot, hud.get_player(), "crush_damage_protection"),
        slashing_d_p = e_search.get_equipment_characteristics(controller.equipment[id], controller.choosen_slot, hud.get_player(), "slashing_damage_protection"),
        piercing_d_p = e_search.get_equipment_characteristics(controller.equipment[id], controller.choosen_slot, hud.get_player(), "piercing_damage_protection")
    }))
end