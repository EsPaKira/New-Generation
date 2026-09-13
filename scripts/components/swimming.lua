-- Original code - NotSurvival by kotisoff
-- Protected by MIT license
-- https://github.com/kotisoff/NotSurvival
local m = _G["$Multiplayer"]
local newgen_utils = require "utils"
local body = entity.rigidbody
local eid = entity:get_uid()

local swim_speed = 3.5

local is_server_side = (m.side == "server") 


function on_physics_update()
    if is_server_side then return end

    local pid = entity:get_player()
    if pid == -1 or pid ~= hud.get_player() then return end
    if player.is_flight(pid) or player.is_noclip(pid) then return end

    if newgen_utils.is_in_water(eid) then
        local vel = body:get_vel()
        local horizontal_speed = (vel[1] * vel[1] + vel[3] * vel[3]) ^ 0.5

        if horizontal_speed > swim_speed then
            local multiplier = swim_speed / horizontal_speed
            vel[1] = vel[1] * multiplier
            vel[3] = vel[3] * multiplier
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