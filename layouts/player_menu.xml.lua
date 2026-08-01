local characters = require "characters/main"
local equipment = require "characters/equipment"
local api = require "api/api_main"

local controller = {
    equipment = nil,
    choosen_slot = nil,
    choosen_equipment = nil,
    choosen_character = nil
}


function load_bg()
    document["background"].src = api.get_background()
end

function click_sound()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
end

function go_back()
    click_sound()
    hud.close("newgen:player_menu")

    hide_characteristics()

    hud.open_inventory()
end

function open_tree(tree)
    click_sound()
    hud.open_permanent("newgen:" .. tree .. "_tree")
end



-- #################### --
-- CHARACTERISTICS MENU --
-- #################### --

local MAX_STATS_CACHE = {
    health = "max_health",
    oxygen = "max_oxygen",
    archium = "max_archium",
    hunger = "max_hunger"
}

local PERCENT_STATS_CACHE = {
    crushing_damage_protection = true,
    slashing_damage_protection = true,
    piercing_damage_protection = true
}

local animation_data = {
    current_x = -400,
    target_x = nil,
    speed = 20,
    width = 400
}

-- functions --

function open_characteristics()
    if animation_data.current_x ~= -animation_data.width and animation_data.current_x ~= 0 then
        return
    end
    if animation_data.target_x == 0 and animation_data.current_x == 0 then
        close_characteristics()
        return
    end

    click_sound()

    document["close_c_panel"].visible = true
    start_characteristics_panel_animation(0)

    local stats = characters.get_group(hud.get_player(), controller.choosen_character, "stats")

    for key, value in pairs(stats) do
        if MAX_STATS_CACHE[key] then
            document[MAX_STATS_CACHE[key]].text = string.format("%d/%d", value, stats[MAX_STATS_CACHE[key]])
        elseif PERCENT_STATS_CACHE[key] then
            document[key].text = string.format("%d%%", value * 100)
        elseif key:sub(1, 4) ~= "max_" then
            document[key].text = tostring(value)
        end
    end
end

function close_characteristics()
    if animation_data.current_x ~= 0 then
        return
    end
    click_sound()
    document["close_c_panel"].visible = false
    start_characteristics_panel_animation(-animation_data.width)
end

function hide_characteristics()
    document["c_panel"].pos = {-400, 0}
    document["close_c_panel"].visible = false
    animation_data.target_x = nil
end

function start_characteristics_panel_animation(target_x) -- КОСТЫЛЬ. Потом заменить на :clearInterval()
    if animation_data.target_x == target_x or document["characteristics_animation"].exists then return end

    animation_data.target_x = target_x

    if document["characteristics_animation"].exists then
        document["characteristics_animation"]:destruct()
    end

    document["animation_manager"]:add("<container id='characteristics_animation'></container>")
    document["characteristics_animation"]:setInterval(10, move_characteristics_panel)
end

function move_characteristics_panel()
    if animation_data.current_x < animation_data.target_x then
        animation_data.current_x = math.min(animation_data.current_x + animation_data.speed, animation_data.target_x)
    else
        animation_data.current_x = math.max(animation_data.current_x - animation_data.speed, animation_data.target_x)
    end

    document["c_panel"].pos = {animation_data.current_x, 0}

    if animation_data.current_x == animation_data.target_x then
        document["characteristics_animation"]:destruct()
    end
end



-- ############## --
-- EQUIPMENT MENU --
-- ############## --

local EQUIPMENT_SLOTS = {"head", "helmet", "body", "chestplate", "cloak", "gloves", "belt", "legs", "greaves", "boots"}

function open_equipment_menu(slot)
    click_sound()
    choose_equipment_slot(slot)

    hide_characteristics()

    document["first_menu"].visible = false
    document["equipment_menu"].visible = true
end

function close_equipment_menu()
    click_sound()
    document["equipment_menu"].visible = false
    document["equipment_list"].visible = false
    document["first_menu"].visible = true
end

function choose_equipment_slot(new_slot)
    click_sound()
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

function open_equipment_list()
    document["equipment_list"]:clear()
    document["equipment_list"].visible = true

    show_equipped_item()
    document["choosen_item_info"]:clear()

    controller.equipment = equipment.search_equipment_by_tag(player.get_inventory(hud.get_player()), controller.choosen_slot)

    if #controller.equipment == 0 then return end

    local e_cols = math.ceil(#controller.equipment / 5)

    local index = 0
    for col = 0, e_cols - 1 do
        for row = 0, 4 do
            index = index + 1
            if index > #controller.equipment then return end

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
        absolute_d_p = equipment.get_equipment_stat(itemid, "absolute_damage_protection"),
        crushing_d_p = equipment.get_equipment_stat(itemid, "crushing_damage_protection") * 100 .. "%",
        slashing_d_p = equipment.get_equipment_stat(itemid, "slashing_damage_protection") * 100 .. "%",
        piercing_d_p = equipment.get_equipment_stat(itemid, "piercing_damage_protection") * 100 .. "%"
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

function equipment_button(action)
    click_sound()
    local pid = hud.get_player()
    local equipped_item = equipment.get_equipment_by_slot(pid, controller.choosen_character, controller.choosen_slot)

    if action == "equip" then
        local new_equipment = item.name(controller.equipment[controller.choosen_equipment])
        local equip_res = equipment.equip(pid, controller.choosen_character, controller.choosen_slot, item.name(controller.equipment[controller.choosen_equipment]), action)
        if not equip_res then return end

        local slot = inventory.find_by_item(player.get_inventory(pid), controller.equipment[controller.choosen_equipment])
        inventory.set(player.get_inventory(pid), slot, equipped_item, 1)
    else
        if equipped_item == 0 then return end

        local slot = inventory.find_by_item(player.get_inventory(pid), 0)
        if not slot then
            document["cannot_remove_item"].visible = true
            return
        end

        local equip_res = equipment.equip(pid, controller.choosen_character, controller.choosen_slot, item.name(equipped_item), action)
        if not equip_res then return end
        
        inventory.set(player.get_inventory(pid), slot, equipped_item, 1)
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
    local pid = hud.get_player()

    document["choosen_item_info"]:add(gui.template("choosen_equipment_info", {
        src = item.icon(itemid),
        heat_p = equipment.get_compared_stat(pid, controller.choosen_character, controller.choosen_slot, itemid, "heat_preservation"),
        heat_r = equipment.get_compared_stat(pid, controller.choosen_character, controller.choosen_slot, itemid, "heat_reflection"),
        absolute_d_p = equipment.get_compared_stat(pid, controller.choosen_character, controller.choosen_slot, itemid, "absolute_damage_protection"),
        crushing_d_p = equipment.get_compared_stat(pid, controller.choosen_character, controller.choosen_slot, itemid, "crushing_damage_protection", true),
        slashing_d_p = equipment.get_compared_stat(pid, controller.choosen_character, controller.choosen_slot, itemid, "slashing_damage_protection", true),
        piercing_d_p = equipment.get_compared_stat(pid, controller.choosen_character, controller.choosen_slot, itemid, "piercing_damage_protection", true)
    }))
end

function choose_equipment_xml(new_equipment)
    click_sound()
    if new_equipment == controller.choosen_equipment then
        return
    end
    if new_equipment then
        document["equipment_cell_" .. new_equipment].color = {100, 100, 100, 100}
    end
    if controller.choosen_equipment then
        document["equipment_cell_" .. controller.choosen_equipment].color = {255, 255, 255, 0}
        document["equipment_cell_" .. controller.choosen_equipment].hoverColor = {100, 100, 100, 100}
    end
    controller.choosen_equipment = new_equipment
end



-- ############ --
-- START SCRIPT --
-- ############ --

function on_open()
    controller.choosen_equipment = nil
    controller.choosen_character = characters.get_choosen_character(hud.get_player())
    document["character_name"].text = gui.str(characters.get_character(hud.get_player(), controller.choosen_character)["full-name"])
    
    hide_characteristics()
    close_equipment_menu()

    for _, slot in ipairs(EQUIPMENT_SLOTS) do
        show_equipped_item_in_main_menu(slot)
    end

    load_bg()
end