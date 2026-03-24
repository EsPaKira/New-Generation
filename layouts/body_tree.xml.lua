local ST = require "skill_trees"

local controller = {
    skill = {}
}


function go_back()
    hud.close("newgen:body_tree")
end

function toggle_skill_info(skill_name)
    if document["skill_info"].visible then
        document["skill_info"].visible = false
        return
    end
    document["skill_info"].visible = true

    local skill = file.read_combined_object("skills/body/" .. skill_name .. ".json")
    local skill_level = ST.get("player")[skill.id]
    if skill_level == nil then
        skill_level = {}
    end

    document["skill_image"].src = "gui/" .. skill_name
    document["skill_frame"].src = "gui/unactive_frame"
    document["skill_name"].text = skill.name .. "  " .. (skill_level["level"] or 0) .. "/" .. skill["max-level"]
    document["skill_description"].text = skill.description

    controller.skill = skill
end

function close_skill_info()
    document["skill_info"].visible = false
end

function research_skill()
    ST.levelup("player", hud.get_player(), controller.skill)
    document["skill_name"].text = controller.skill.name .. "  " .. (ST.get("player")[controller.skill.id]["level"] or 0) .. "/" .. controller.skill["max-level"]
end