local characters = require "characters/characters_main"
local skill_trees = require "characters/characters_skill_trees"

local controller = {
    skill = {}
}
local SKILLS_IN_THIS_TREE = {"accuracy", "agility", "bigger_lungs", "body_skill", "survivability"}

function go_back()
    hud.close("newgen:body_tree")
    document["skill_info"].visible = false
end

function toggle_skill_info(skill_name)
    if skill_name == controller.skill.id and document["skill_info"].visible then
        document["skill_info"].visible = false
        return
    end
    document["skill_info"].visible = true

    local character_skill_level, skill = skill_trees.get_skill_data(hud.get_player(), characters.get_choosen_character(hud.get_player()), "body", skill_name)

    document["skill_image"].src = "gui/" .. skill_name
    document["skill_frame"].src = "gui/unactive_frame"
    document["skill_name"].text = gui.str(skill.name) .. "  " .. character_skill_level .. "/" .. skill["max-level"]
    document["skill_description"].text = gui.str(skill.description)

    controller.skill = skill
end

function close_skill_info()
    document["skill_info"].visible = false
end

function research_skill()
    local result = skill_trees.levelup(hud.get_player(), characters.get_choosen_character(hud.get_player()), "body", controller.skill.id)
    local character_skill_level, skill = skill_trees.get_skill_data(hud.get_player(), characters.get_choosen_character(hud.get_player()), "body", controller.skill.id)
    document["skill_name"].text = gui.str(controller.skill.name) .. "  " .. character_skill_level .. "/" .. controller.skill["max-level"]

    if result then
        update_ui(controller.skill.id, skill["active-path"])
    end
end

function update_ui(skill_id, skill_path)
    document[skill_id .. "_frame"].src = "gui/active_frame"
    document[skill_id .. "_shadow"].color = {0, 0, 0, 0}
    document[skill_id .. "_shadow"].hoverColor = {50, 50, 50, 100}
    if skill_path then
        document[skill_id .. "_path"].src = skill_path
    end
end

function on_open()
    local all_skills = characters.get_group(hud.get_player(), characters.get_choosen_character(hud.get_player()), "skills")
    local found = {}
    for researched_skill, value in pairs(all_skills) do
        for _, base_skill in ipairs(SKILLS_IN_THIS_TREE) do
            if researched_skill == base_skill then
                local _, skill = skill_trees.get_skill_data(hud.get_player(), characters.get_choosen_character(hud.get_player()), "body", researched_skill)
                update_ui(researched_skill, skill["active-path"])
                break
            end
        end
    end
end