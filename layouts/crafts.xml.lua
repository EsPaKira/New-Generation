-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival
local crafting = require "crafting"

local controller = {
    max_crafts = 0,
    craft_category = 0,
    invid = 0,
    count = 0,
    shown_crafts = {},
    selected_craft = nil,
    components = {}, -- [index] = comp ({id = ...} or {tag = ...})
    component_page = 1,
    component_pages = {}, -- array[ [type_of_page, craft_group, data], ... ] <--> type_of_page = "text" or "craft"
    component_history = {} -- array[ [comp, component_page], ... ]
}

local CRAFT_ROWS = 9
local CRAFT_COLS = 10
local craft_buttons = {}


local function tag_name(tag)
    return tag:match(":(.+)") or tag
end

local function update_craft_button(craft)
    local is_enough = crafting.is_enough(craft.recipe_id, controller.invid)
    local btn = document["craft_info_button"]
    btn.enabled = is_enough
    btn.color = is_enough and {14, 230, 14, 80} or {230, 14, 14, 40}
    btn.hoverColor = is_enough and {2, 54, 2, 255} or {230, 14, 14, 40}
end

local function display_craft(craft, button)
    local is_enough = crafting.is_enough(craft.recipe_id, controller.invid)
    for i, node in ipairs(button) do
        node.visible = true
        if i == 2 then
            node.color = is_enough and {14, 230, 14, 80} or {230, 14, 14, 80}
        else
            node.src = item.icon(item.index(craft.results[1].id))
        end
    end
end

local function refresh_crafts(invid)
    categories = {"primitive"}
    if controller.craft_category ~= 0 and controller.craft_category ~= "primitive" then
        table.insert(categories, controller.craft_category)
    end

    local shown_crafts = {}
    local seen_items = {}
    for slot = 0, inventory.size(invid) - 1 do
        local id = inventory.get(invid, slot)
        if id ~= 0 and not seen_items[id] then
            seen_items[id] = true
            for _, category in ipairs(categories) do
                for _, craft in ipairs(crafting.find_all_containing(category, id)) do
                    if not table.has(shown_crafts, craft) then
                        table.insert(shown_crafts, craft)
                    end
                end
            end
        end
    end

    table.sort(shown_crafts, function(a, b)
        return a.recipe_id < b.recipe_id
    end)
    controller.shown_crafts = shown_crafts

    local shown_crafts_count = math.min(controller.max_crafts, #shown_crafts)
    for i = 0, shown_crafts_count - 1 do
        display_craft(shown_crafts[i + 1], craft_buttons[i + 1])
    end
    for i = shown_crafts_count, controller.max_crafts - 1 do
        for _, node in ipairs(craft_buttons[i + 1]) do
            node.visible = false
        end
    end
end

local function display_components(craft, element)
    for _, comp in ipairs(craft.components) do
        controller.count = controller.count + 1
        controller.components[controller.count] = comp

        local src
        if comp.id then
            src = item.icon(item.index(comp.id))
        else
            src = "gui/" .. tag_name(comp.tag)
        end

        document[element]:add(gui.template("craft_component", {
            index = controller.count,
            src = src,
            text = crafting.get_component_count(controller.invid, comp) .. "/" .. comp.count
        }), controller)
    end
end

local function refresh_components(craft)
    for i, comp in ipairs(craft.components) do
        document["craft_component_text_" .. i].text = crafting.get_component_count(controller.invid, comp) .. "/" .. comp.count
    end
end

local function refresh_info(craft)
    local craft = controller.selected_craft
    if craft and document["craft_info"].visible then
        refresh_components(craft)
        update_craft_button(craft)
    end
end

function on_items_update()
    refresh_crafts(controller.invid)
    refresh_info()
end

function on_open(craft_category)
    document["crafts_header"].text = craft_category == 0 and gui.str("Crafts") or gui.str("Crafts on " .. craft_category)

    controller.count = 0
    controller.craft_category = craft_category
    controller.components = {}
    controller.component_page = 1
    controller.component_pages = {}
    controller.component_history = {}
    controller.selected_craft = nil
    controller.invid = player.get_inventory(hud.get_player())

    if controller.max_crafts == 0 then
        for row = 0, CRAFT_ROWS - 1 do
            for col = 0, CRAFT_COLS - 1 do
                local index = row * CRAFT_COLS + col
                document["crafts_table"]:add(gui.template("craft_cell", {
                    x = 5 + col * 75,
                    y = 5 + row * 75,
                    index = index,
                }), controller)
                controller.max_crafts = controller.max_crafts + 1
                table.insert(craft_buttons, document["craft_slot_" .. index])
            end
        end
    end

    refresh_crafts(controller.invid)
    hide_info("craft", true)
    hide_info("component", true)
end

function craft()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    local craft = controller.selected_craft
    if not craft then return end
    
    crafting.try_craft(craft.recipe_id)
end

function controller:show_info(index)
    local craft = self.shown_crafts[index + 1]
    if not craft then
        audio.play_sound_2d("ui/button_click", 1, 1, "ui")
        return
    end
    controller.count = 0
    controller.selected_craft = craft
    hide_info("component")

    document["craft_info_img"].src = item.icon(item.index(craft.results[1].id))
    document["craft_info_name"].text = gui.str(item.caption(item.index(craft.results[1].id)))
    document["craft_info_components"]:clear()
    display_components(craft, "craft_info_components")
    document["craft_info"].visible = true

    update_craft_button(craft)
end

function controller:show_component_info(index)
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    controller.component_page = 1

    local comp = controller.components[index]
    if comp then
        display_component_info(comp, true, nil)
    end
end

function display_component_info(comp, save, page)
    controller.component_page = page or 1
    local component_pages = {}

    document["component_info"].visible = true

    if comp.id then
        local itemid = item.index(comp.id)
        document["component_info_img"].src = itemid
        document["component_info_name"].text = gui.str(item.caption(itemid))

        for _, found in ipairs(crafting.find_all_results(itemid)) do
            table.insert(component_pages, {"craft", found[1], found[2]})
        end
    else
        local name = tag_name(comp.tag)
        document["component_info_img"].src = "gui/" .. name
        document["component_info_name"].text = gui.str("material") .. ": " .. gui.str(name)

        local path = file.find("materials/" .. name .. ".txt")
        if path then
            table.insert(component_pages, {"text", file.read(path)})
        end
    end
    controller.component_pages = component_pages
    if save then
        table.insert(controller.component_history, {comp, controller.component_page})
    end

    document["component_go_back"].visible = #controller.component_history >= 2

    refresh_component_info()
end

function refresh_component_info()
    if #controller.component_pages > 1 then
        document["component_info_switch"].visible = true 
        document["component_info_pages"].text = controller.component_page .. "/" .. #controller.component_pages
    else
        document["component_info_switch"].visible = false
    end

    document["component_info_components"]:clear()
    document["component_info_components"].visible = true

    local data = controller.component_pages[controller.component_page] or {}
    if data[1] == "text" then
        document["component_info_components"]:add("<container size='300,200'><label id='component_info_description' size='284,196' pos='8,4' multiline='true' text-wrap='true'></label></container>")
        document["component_info_description"].text = gui.str(data[2])
    elseif data[1] == "craft" then
        if data[2] ~= "primitive" then
            document["component_info_components"]:add("<container size='300,25'><label text-align='center' gravity='center-center' color='#8b8b8b'>" .. gui.str(data[2]) .."</label></container>")
        end
        display_components(data[3], "component_info_components")
    else
        document["component_info_components"].visible = false
    end
end

function move(number)
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    controller.component_page = controller.component_page + number

    if controller.component_page > #controller.component_pages then
        controller.component_page = 1
    elseif controller.component_page == 0 then
        controller.component_page = #controller.component_pages
    end

    controller.component_history[#controller.component_history][2] = controller.component_page
    refresh_component_info()
end

function hide_info(id, should_play_sound)
    if not should_play_sound then
        audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    end
    document[id .. "_info"].visible = false
    document[id .. "_info_components"]:clear()

    if id == "component" then
        controller.component_history = {}
    elseif id == "craft" then
        controller.selected_craft = nil
    end
end

function go_back()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    hud.close("newgen:crafts")

    if controller.craft_category == 0 then
        hud.open_inventory()
        hud.open_permanent("newgen:side_menu")
    end
end

function component_go_back()
    audio.play_sound_2d("ui/button_click", 1, 1, "ui")
    table.remove(controller.component_history)
    local last = controller.component_history[#controller.component_history]
    display_component_info(last[1], false, last[2])
end
