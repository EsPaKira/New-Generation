-- Original code - NotSurvival by kotisoff
-- Protected by MIT license
-- https://github.com/kotisoff/NotSurvival


local body = entity.rigidbody
local tsf = entity.transform

local function is_flight(eid)
    if eid == player.get_entity(hud.get_player()) then
        local pid = entity:get_player()
        return player.is_flight(pid) or player.is_noclip(pid)
    end
end

local water = block.index("base:water")


function entity_pos()
    local pos = tsf:get_pos()
    pos[1] = pos[1] - 1
    pos[3] = pos[3] - 1
    return pos
end

local function is_in_water()
    local pos = entity_pos()
    return block.get(pos[1], pos[2] + 0.1, pos[3]) == water or block.get(pos[1], pos[2] + 1, pos[3]) == water
end

function head_underwater()
    local pos = entity_pos()
    return block.get(pos[1], pos[2] + 0.8, pos[3]) == water
end

local function body_underwater()
    local pos = entity_pos()
    return block.get(pos[1], pos[2] + 0.4, pos[3]) == water
end

local swim_speed = 3.5

function on_physics_update()
    local eid = entity:get_uid()
    if is_flight(eid) then
        return
    end

    if is_in_water() then
        local vel = body:get_vel()

        if vec3.length({ vel[1], 0, vel[3] }) > swim_speed then
            vel[1], _, vel[3] = unpack(vec3.mul(vec3.normalize({ vel[1], vel[2], vel[3] }), swim_speed))
        end
        if vel[2] < -1.8 then 
            vel[2] = math.abs(vel[2]) * -0.9 
        end

        if not hud.is_inventory_open() then
            if input.is_active("movement.jump") then
                if not body_underwater() then
                    vel[2] = 7
                else
                    vel[2] = 2
                end
            end
            if input.is_active("movement.crouch") then
                vel[2] = -3
            end
        end
        body:set_vel(vel)
    end
end