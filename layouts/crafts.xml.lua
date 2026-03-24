-- Original code - base_survival by MihailRis

local crafting = require "crafting"

local controller = {
    stats = {}, --id: count,...
    invsize = 0,
    max_crafts = 0,
    item_index = 0,
    type_of_crafts = nil
}

local CRAFT_ROWS = 9
local CRAFT_COLS = 10
local craft_buttons = {}

local function display_craft(craft, button, stats)
    for i, node in ipairs(button) do
        if i == 2 then
            local is_enough = crafting.is_enough(craft, stats)
            node.visible = true
            node.color = is_enough and {14, 230, 14, 80} or {230, 14, 14, 80}
        else
            node.visible = true
            node.src = item.icon(item.index(craft.results[1].id))
        end
    end
end

local function refresh_crafts(invid)
    local stats = {}
    local invsize = inventory.size(invid)

    local shown_crafts = {}
    for i=0,invsize-1 do
        local id, count = inventory.get(invid, i)
        stats[id] = (stats[id] or 0) + count

        local name = item.name(id)

        local found = crafting.find_all_containing(name)
        for j, craft in ipairs(found) do
            if not table.has(shown_crafts, craft) then
                table.insert(shown_crafts, craft)
            end
        end
    end
    controller.stats = stats
    controller.invsize = invsize
    controller.shown_crafts = shown_crafts

    local shown_crafts_count = math.min(controller.max_crafts, #shown_crafts)
    for i=0,shown_crafts_count-1 do
        local craft = shown_crafts[i + 1]
        local craft_button = craft_buttons[i + 1]
        display_craft(craft, craft_button, stats)
    end
    for i=shown_crafts_count,controller.max_crafts-1 do
        local craft_button = craft_buttons[i + 1]
        for _, node in ipairs(craft_button) do
            node.visible = false
        end
    end
end

local function display_components(craft)
    for i, comp in ipairs(craft.components) do
        document["craft_info_components"]:add(gui.template("craft_component", {
            index = i,
            src = item.icon(item.index(craft.components[i].id)),
            text = (controller.stats[item.index(craft.components[i].id)] or 0).."/"..craft.components[i].count
        }))
    end
end

local function refresh_components(craft)
    for i, comp in ipairs(craft.components) do
        document["craft_component_text_"..i].text = (controller.stats[item.index(craft.components[i].id)] or 0).."/"..craft.components[i].count
    end
end

function on_items_update(invid, slotid)
    refresh_crafts(invid)
end

function on_open(type_of_crafts)
    crafting.add_workbench_crafts(type_of_crafts)
    document["crafts_header"].text = type_of_crafts == 0 and gui.str("Crafts") or gui.str("Crafts on " .. type_of_crafts)
    controller.type_of_crafts = type_of_crafts

    local pid = hud.get_player()
    local pinvid = player.get_inventory(pid)
    controller.invid = pinvid
    if controller.max_crafts == 0 then
        for row=0, CRAFT_ROWS-1 do
            for col=0, CRAFT_COLS-1 do
                local index = row * CRAFT_COLS + col
                document["crafts_table"]:add(gui.template("craft_cell", {
                    x = 5 + col * 75,
                    y = 5 + row * 75,
                    index = index,
                }), controller)
                controller.max_crafts = controller.max_crafts + 1
                table.insert(craft_buttons, document["craft_slot_"..index])
            end
        end
    end
    refresh_crafts(pinvid)
    hide_info()
end

function craft()
    local pid = hud.get_player()
    local pinvid = player.get_inventory(pid)
    local craft = controller.shown_crafts[controller.item_index + 1]
    crafting.remove_from(craft, controller.invid)
    for i, result in ipairs(craft.results) do
        local overflow = inventory.add(controller.invid, item.index(result.id), result.count)
        if overflow > 0 then
            inventory.add(pinvid, item.index(result.id), overflow)
        end
    end
    refresh_crafts(controller.invid)
    refresh_components(craft)
    local is_enough = crafting.is_enough(craft, controller.stats)
    document["craft_info_button"].enabled = is_enough
    document["craft_info_button"].color = is_enough and {14, 230, 14, 80} or {230, 14, 14, 40}
    document["craft_info_button"].hoverColor = is_enough and {2, 54, 2, 255} or {230, 14, 14, 40}
end

function controller:show_info(index)
    local craft = self.shown_crafts[index + 1]
    if not craft then
        return
    end
    document["craft_info_img"].src = item.icon(item.index(craft.results[1].id))
    document["craft_info_name"].text = gui.str(item.caption(item.index(craft.results[1].id)))
    document["craft_info_components"]:clear()
    display_components(craft)
    document["craft_info"].visible = true

    local is_enough = crafting.is_enough(craft, self.stats)
    document["craft_info_button"].enabled = is_enough
    document["craft_info_button"].color = is_enough and {14, 230, 14, 80} or {230, 14, 14, 40}
    document["craft_info_button"].hoverColor = is_enough and {2, 54, 2, 255} or {230, 14, 14, 40}
    controller.item_index = index
end

function hide_info()
    document["craft_info"].visible = false
    document["craft_info_components"]:clear()
end

function go_back()
    hud.close("newgen:crafts")

    if controller.type_of_crafts == 0 then
        hud.open_inventory()
        hud.open_permanent("newgen:player_button")
    end
end