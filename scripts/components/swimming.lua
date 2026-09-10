-- Original code - NotSurvival by kotisoff
-- Protected by MIT license
-- https://github.com/kotisoff/NotSurvival

local m = _G["$Multiplayer"]
local body = entity.rigidbody
local tsf = entity.transform

local water_id = block.index("base:water")
local swim_speed = 3.5


local function is_flight()
    local pid = entity:get_player()
    if pid == -1 then return false end
    return player.is_flight(pid) or player.is_noclip(pid)
end

function entity_pos()
    local pos = tsf:get_pos()
    pos[1] = math.floor(pos[1])
    pos[3] = math.floor(pos[3])
    return pos
end

local function is_in_water()
    local pos = entity_pos()
    return block.get(pos[1], pos[2] - 0.3, pos[3]) == water_id or block.get(pos[1], pos[2] + 1, pos[3]) == water_id
end

function head_underwater()
    local pos = entity_pos()
    return block.get(pos[1], pos[2] + 0.8, pos[3]) == water_id
end

local function body_underwater()
    local pos = entity_pos()
    return block.get(pos[1], pos[2], pos[3]) == water_id
end

local function is_local_player()
    local pid = entity:get_player()
    return pid ~= -1 and pid == hud.get_player()
end

function on_physics_update()
    if m.side == "server" then return end
    if not is_local_player() then return end
    if is_flight() then return end

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