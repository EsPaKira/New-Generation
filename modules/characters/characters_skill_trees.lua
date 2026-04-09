local characters = require "characters/characters_main"

local skill_trees = {}


function skill_trees.levelup(pid, character_name, skill_tree_name, skill_name)
    local character_skill_level, skill, character = skill_trees.get_skill_data(pid, character_name, skill_tree_name, skill_name)
    -- if no data about character then character_skill_level == false
    if not character_skill_level then return false end

    if skill_trees.check_requirements(character, skill, character_skill_level) then
        characters.set_field(pid, character_name, "skills", skill_name, (character_skill_level + 1))
        skill_trees.set_skill_buffs(pid, character_name, skill)
        return true
    end
    return false
end

function skill_trees.check_requirements(character, skill, character_skill_level)
    if (character_skill_level + 1) > skill["max-level"] then return false end
    if not skill["required-skills"] then return true end

    for _, req in ipairs(skill["required-skills"]) do
        if not character.skills[req.id] then return false end -- there will be more difficult system in the future
    end
    return true
end

function skill_trees.get_skill_data(pid, character_name, skill_tree_name, skill_name)
    local character = characters.get_character(pid, character_name)
    if not character then return false end

    local skill = file.read_combined_object("skills/" .. skill_tree_name .. "/" .. skill_name .. ".json")
    local character_skill_level = characters.get_field(pid, character_name, "skills", skill_name)

    if not character_skill_level then
        character_skill_level = 0
    end

    return character_skill_level, skill, character
end

function skill_trees.set_skill_buffs(pid, character_name, skill)
    for _, buff in ipairs(skill["stats-buffs"]) do
        local old_value = characters.get_field(pid, character_name, "stats", buff.id)
        characters.set_field(pid, character_name, "stats", buff.id, (old_value + buff.value))
    end
    characters.update_survival_ui(pid, character_name)
end

return skill_trees