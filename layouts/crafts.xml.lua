-- Original code - base_survival by MihailRis
-- Protected by MIT license
-- https://github.com/MihailRis/base_survival

local crafting = require "crafting"
local base_util = require "base:util"

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
        local name = item.name(id)
        local craft_material = item.properties[id]["newgen:craft-material"]

        stats[id] = (stats[id] or 0) + count
        if craft_material then
            stats[craft_material] = (stats[craft_material] or 0) + count
        end

        local found = crafting.find_all_containing(name, craft_material)
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
            src = item.icon(item.index(comp.id)) or ("gui/" .. comp.tag) or "gui/error",
            text = get_items_count(controller.invid, comp) .. "/" .. comp.count
        }))
    end
end

local function refresh_components(craft)
    for i, comp in ipairs(craft.components) do
        document["craft_component_text_"..i].text = get_items_count(controller.invid, comp) .. "/" .. comp.count
    end
end

function on_items_update(invid)
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
            local pos = {player.get_pos(hud.get_player())}
            local drop = base_util.drop(pos, item.index(result.id), overflow)
            drop.rigidbody:set_vel(vec3.spherical_rand(8.0))
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

function get_items_count(invid, comp)
    if comp.id then
        return (controller.stats[item.index(comp.id)] or 0)
    end
    return (controller.stats[comp.tag] or 0)
end