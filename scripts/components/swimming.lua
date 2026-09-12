-- Original code - NotSurvival by kotisoff
-- Protected by MIT license
-- https://github.com/kotisoff/NotSurvival
local m = _G["$Multiplayer"]
local body = entity.rigidbody
local newgen_utils = require "utils"

local swim_speed = 3.5


local function is_flight()
    local pid = entity:get_player()
    if pid == -1 then return false end
    return player.is_flight(pid) or player.is_noclip(pid)
end

local function is_local_player()
    local pid = entity:get_player()
    return pid ~= -1 and pid == hud.get_player()
end

function on_physics_update()
    if m.side == "server" then return end
    if not is_local_player() then return end
    if is_flight() then return end
    local eid = entity:get_uid()

    if newgen_utils.is_in_water(eid) then
        local vel = body:get_vel()

        if vec3.length({ vel[1], 0, vel[3] }) > swim_speed then
            vel[1], _, vel[3] = unpack(vec3.mul(vec3.normalize({ vel[1], vel[2], vel[3] }), swim_speed))
        end
        if vel[2] < -1.8 then 
            vel[2] = math.abs(vel[2]) * -0.9 
        end

        if not hud.is_inventory_open() then
            if input.is_active("movement.jump") then
                if not newgen_utils.is_body_underwater(eid) then
                    vel[2] = 6
                else
                    vel[2] = 3
                end
            end
            if input.is_active("movement.crouch") then
                vel[2] = -3
            end
        end
        body:set_vel(vel)
    end
end