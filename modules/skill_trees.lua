local skill_trees = {
    characters = {}
}


function skill_trees.levelup(cname, cid, skill)
    local character = skill_trees.get(cname)
    if character[skill.id] == nil then
        character[skill.id] = {}
    end

    if skill["required-skills"] then
        for _, req in ipairs(skill["required-skills"]) do
            if not character[req.id] then return end
        end
    end

    local current_level = character[skill.id]["level"] or 0
    if current_level >= skill["max-level"] then return end

    for _, buff in ipairs(skill["stats-buffs"]) do
        skill_trees.set(cname, cid, "stats-buffs", buff.id, buff.buff)
    end
    skill_trees.set(cname, cid, skill.id, "level", 1)
end

function skill_trees.set(cname, cid, skill_id, key, value)
    local character = skill_trees.get(cid)
    if character[skill_id] == nil then
        character[skill_id] = {}
    end
    if character[skill_id][key] == nil then
        character[skill_id][key] = value
    else
        character[skill_id][key] = (character[skill_id][key] or 0) + value
    end
    
    if key == "level" then return end
    
    local pentity = entities.get(player.get_entity(cid))
    local cm = pentity:get_component("newgen:characteristics_manager")
    --cm.set_params(key, cm["get_" .. key]() + value)
end

function skill_trees.get(cname)
    if skill_trees.characters[cname] == nil then
        skill_trees.characters[cname] = {}
    end
    return skill_trees.characters[cname]
end

function skill_trees.open(data)
    skill_trees.characters = data
end

return skill_trees