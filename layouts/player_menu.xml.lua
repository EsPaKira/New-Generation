local characters = require "characters/characters_main"
local equipment = require "characters/characters_equipment"

local controller = {
    equipment = nil,
    choosen_slot = nil,
    choosen_equipment = nil,
    choosen_character = nil
}

function go_back()
    hud.close("newgen:player_menu")
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
    local stats = characters.get_group(hud.get_player(), controller.choosen_character, "stats")
    for key, value in pairs(stats) do
        if key == "health" or key == "oxygen" or key == "archium" then
            document["max_".. key].text = value .. "/" .. stats["max_" .. key]
        elseif key ~= "max_health" and key ~= "max_oxygen" and key ~= "max_archium" then
            document[key].text = tostring(value)
        end
    end
end

function close_c_panel()
    document["c_panel"].visible = false
    document["close_c_panel"].visible = false
end

function open_equipment_menu(slot)
    choose_equipment_slot(slot)
    close_c_panel()
    document["first_menu"].visible = false
    document["equipment_menu"].visible = true
end

function close_equipment_menu()
    document["equipment_menu"].visible = false
    document["equipment_list"].visible = false
    document["first_menu"].visible = true
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

    controller.equipment = equipment.search_equipment_by_tag(player.get_inventory(hud.get_player()), controller.choosen_slot)
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
    local itemid = equipment.get_equipment_by_slot(hud.get_player(), controller.choosen_character, controller.choosen_slot)
    if itemid == 0 then
        document["equipped_item_info"]:add(gui.template("no_equipment_info"))
        return
    end
    document["equipped_item_info"]:add(gui.template("equipment_info", {
        src = item.icon(itemid),
        heat_p = equipment.get_equipment_stat(itemid, "heat_preservation"),
        heat_r = equipment.get_equipment_stat(itemid, "heat_reflection"),
        crush_d_p = equipment.get_equipment_stat(itemid, "crush_damage_protection"),
        slashing_d_p = equipment.get_equipment_stat(itemid, "slashing_damage_protection"),
        piercing_d_p = equipment.get_equipment_stat(itemid, "piercing_damage_protection")
    }))
end

function show_equipped_item_in_main_menu(slot)
    local item_in_slot = equipment.get_equipment_by_slot(hud.get_player(), controller.choosen_character, slot)
    if item_in_slot ~= 0 then
        document[slot].src = item.icon(item_in_slot)
    else 
        document[slot].src = "gui/" .. slot
    end
end

function on_open()
    controller.choosen_equipment = nil
    controller.choosen_character = characters.get_choosen_character(hud.get_player())
    close_c_panel()
    close_equipment_menu()
    document["character_name"].text = gui.str(characters.get_character(hud.get_player(), controller.choosen_character)["character_full_name"])

    show_equipped_item_in_main_menu("head")
    show_equipped_item_in_main_menu("helmet")
    show_equipped_item_in_main_menu("cloak")
    show_equipped_item_in_main_menu("body")
    show_equipped_item_in_main_menu("chestplate")
    show_equipped_item_in_main_menu("gloves")
    show_equipped_item_in_main_menu("legs")
    show_equipped_item_in_main_menu("greaves")
    show_equipped_item_in_main_menu("belt")
    show_equipped_item_in_main_menu("boots")
end

function equipment_button(action)
    local equipped_item = equipment.get_equipment_by_slot(hud.get_player(), controller.choosen_character, controller.choosen_slot)
    if action == "equip" then
        if equipped_item ~= 0 then
            local slot = inventory.find_by_item(player.get_inventory(hud.get_player()), controller.equipment[controller.choosen_equipment])
            inventory.set(player.get_inventory(hud.get_player()), slot, equipped_item, 1)
            equipment.equip(hud.get_player(), controller.choosen_character, controller.choosen_slot, item.name(controller.equipment[controller.choosen_equipment]), action)
        else
            local slot = inventory.find_by_item(player.get_inventory(hud.get_player()), controller.equipment[controller.choosen_equipment])
            inventory.set(player.get_inventory(hud.get_player()), slot, 0, 1)
            equipment.equip(hud.get_player(), controller.choosen_character, controller.choosen_slot, item.name(controller.equipment[controller.choosen_equipment]), action)
        end
    else
        if equipped_item ~= 0 then
            local slot = inventory.find_by_item(player.get_inventory(hud.get_player()), 0)
            if slot == nil then
                document["cannot_remove_item"].visible = true
                return
            end

            inventory.set(player.get_inventory(hud.get_player()), slot, equipped_item, 1)
            equipment.equip(hud.get_player(), controller.choosen_character, controller.choosen_slot, item.name(equipped_item), action)
        end
    end
    controller.choosen_equipment = nil
    open_equipment_list()
    show_equipped_item_in_main_menu(controller.choosen_slot)
end

function hide_error_info()
    document["cannot_remove_item"].visible = false
end

function controller:choose_equipment(id)
    document["choosen_item_info"]:clear()
    choose_equipment_xml(id)
    local itemid = controller.equipment[id]

    document["choosen_item_info"]:add(gui.template("choosen_equipment_info", {
        src = item.icon(itemid),
        heat_p = equipment.get_compared_stat(hud.get_player(), controller.choosen_character, controller.choosen_slot, itemid, "heat_preservation"),
        heat_r = equipment.get_compared_stat(hud.get_player(), controller.choosen_character, controller.choosen_slot, itemid, "heat_reflection"),
        crush_d_p = equipment.get_compared_stat(hud.get_player(), controller.choosen_character, controller.choosen_slot, itemid, "crush_damage_protection"),
        slashing_d_p = equipment.get_compared_stat(hud.get_player(), controller.choosen_character, controller.choosen_slot, itemid, "slashing_damage_protection"),
        piercing_d_p = equipment.get_compared_stat(hud.get_player(), controller.choosen_character, controller.choosen_slot, itemid, "piercing_damage_protection")
    }))
end

function open_tree(tree)
    hud.open_permanent("newgen:" .. tree .. "_tree")
end