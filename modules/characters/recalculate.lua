local config = require "api/config"
local equipment = require "characters/equipment"
local skill_trees = require "characters/skill_trees"

local recalculate = {}


function recalculate.auto_load(players)
    if config.data.current_version == config.get_current_v() then
        return false
    else
        recalculate.recalculate(players)
        return true
    end
end

local function recalculate_skills(pid, character_name, skills)
    for key, value in pairs(skills) do
        while value > 0 do
            value = value - 1
            skill_trees.levelup(pid, character_name, key, true)
        end
    end
end

local function recalculate_equipment(pid, character_name, equipment_table)
    for key, value in pairs(equipment_table) do
        equipment.equip(pid, character_name, key, value, "equip")
    end
end

function recalculate.recalculate(players)
    for pid, player_data in pairs(players) do
        for key, character in pairs(player_data) do
            if key ~= "current_version" and key ~= "choosen_character" then
                local skills = character["skills"]
                character["skills"] = {}
                local equipment_table = character["equipment"]
                character["equipment"] = {}

                local data = file.read_combined_object("characters/" .. key .. ".json")
                character["full-name"] = data["full-name"]
                character["stats"] = data["stats"]
                
                recalculate_skills(pid, key, skills)
                recalculate_equipment(pid, key, equipment_table)
            end
        end
        if pid ~= "-1" then
            local c_manager = entities.get(player.get_entity(tonumber(pid))):get_component("newgen:characteristics_manager")
            if c_manager then
                c_manager.set_player(tonumber(pid))
            end
        end
    end
end

return recalculate