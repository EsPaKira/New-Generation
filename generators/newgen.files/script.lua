local _, dir = parse_path(__DIR__)
math.randomseed(SEED)

local function get_rand(seed, x, y, z)
    local h = bit.bxor(bit.bor(x * 23729, y % 16786), y * x + seed)
    h = bit.bxor(h, z * 47917)
    h = bit.bxor(h, bit.bor(z % 12345, x + y))

    local n = (h % 10000) / 10000.0

    return n
end

local function gen_parameters(size, seed, x, y)
    local res = {}
    local rand = 0

    for i=1, size do
        rand = get_rand(seed, x, y, rand)
        table.insert(res, rand)
    end

    return res
end

local RIVER_WIDTH = 0.3

local function gen_hmap(x, y, w, h, s)
    -- NEW GENERATOR
    -- #############
    -- local map = Heightmap(w, h)
    -- map.noiseSeed = SEED
    -- map:noise({x, y}, 0.01*s, 5, 1)
    -- map:mul(0.5)
    -- map:add(0.5)
    -- map:mul(0.22)
    -- map:add(0.28)

    -- local mountain_mask = Heightmap(w, h)
    -- mountain_mask.noiseSeed = SEED + 71
    -- mountain_mask:noise({x+300, y+140}, 0.5, 3, 1)
    -- mountain_mask:mul(0.5)
    -- mountain_mask:add(-0.05)
    -- mountain_mask:mul(2.222)
    -- mountain_mask:max(0.0)
    -- mountain_mask:min(1.0)
    -- mountain_mask:pow(1.5)

    -- local peaks = Heightmap(w, h)
    -- peaks.noiseSeed = SEED + 133
    -- peaks:noise({x+42, y+17}, 0.03*s, 5, 1)
    -- peaks:mul(0.5)
    -- peaks:add(0.5)
    -- peaks:mul(0.27)
    -- peaks:add(0.55)

    -- map:mixin(peaks, mountain_mask)
    -- local river_map = Heightmap(w, h)
    -- river_map.noiseSeed = SEED + 811
    -- river_map:noise({x+21, y+12}, 0.015*s, 4, 1)
    -- river_map:abs()
    -- river_map:mul(1.0 / RIVER_WIDTH)
    -- river_map:min(1.0)
    -- river_map:pow(0.6)
    -- river_map:max(0.3)

    -- map:mul(river_map)

    -- local detail = Heightmap(w, h)
    -- detail.noiseSeed = SEED + 999
    -- detail:noise({x, y}, 0.4*s, 3, 1)
    -- detail:mul(0.5)
    -- detail:add(0.5)
    -- detail:mul(0.03)
    -- detail:add(-0.015)
    -- map:add(detail)

    -- map:max(0.0)
    -- map:min(1.0)


    -- OLD GENERATOR
    -- #############
    local umap = Heightmap(w, h)
    local vmap = Heightmap(w, h)
    umap.noiseSeed = SEED
    vmap.noiseSeed = SEED
    vmap:noise({x+521, y+70}, 0.1*s, 3, 25.8)
    vmap:noise({x+95, y+246}, 0.15*s, 3, 25.8)

    local map = Heightmap(w, h)
    map.noiseSeed = SEED
    map:noise({x, y}, 0.4*s, 5, 0.02)
    map:cellnoise({x, y}, 0.15*s, 3, 0.3, umap, vmap)
    map:add(0.7)

    local rivermap = Heightmap(w, h)
    rivermap.noiseSeed = SEED
    rivermap:noise({x+21, y+12}, 0.1*s, 4)
    rivermap:abs()
    rivermap:mul(2.0)
    rivermap:pow(0.15)
    rivermap:max(0.5)
    map:mul(rivermap)

    local desertmap = Heightmap(w, h)
    desertmap.noiseSeed = SEED
    desertmap:cellnoise({x+52, y+326}, 0.3*s, 2, 0.2)
    desertmap:add(0.6)
    map:mixin(desertmap, umap)

    local mountainsmap = Heightmap(w, h)
    mountainsmap.noiseSeed = SEED
    mountainsmap:noise({x+42, y+17}, 0.2*s, 5, 0.3)
    mountainsmap:add(0.3)
    map:mixin(mountainsmap, umap)

    return map
end

function place_structures(x, z, w, d, hmap, chunk_height)
    local placements = {}

    return placements
end

function place_structures_wide(x, z, w, d, chunk_height)
    local placements = {}
    local rands = gen_parameters(11, SEED, x, z)

    if rands[1] < 0.05 then -- generate caves

        local sx = x + rands[2] * 10 - 5
        local sy = rands[3] * (chunk_height / 4) + 10
        local sz = z + rands[4] * 10 - 5

        local dir = rands[5] * math.pi * 2
        local dir_inertia = (rands[6] - 0.5) * 2
        local elevation = -3
        local width = rands[7] * 3 + 2

        for i=1,18 do
            local dx = math.sin(dir) * 10
            local dz = -math.cos(dir) * 10

            local ex = sx + dx
            local ey = sy + elevation
            local ez = sz + dz

            table.insert(placements, 
                {":line", 0, {sx, sy, sz}, {ex, ey, ez}, width})

            sx = ex
            sy = ey
            sz = ez

            dir_inertia = dir_inertia * 0.8 + 
                (rands[8] - 0.5) * math.pow(rands[9], 2) * 8
            elevation = elevation * 0.9 + 
                (rands[10] - 0.4) * (1.0-math.pow(rands[11], 4)) * 8
            dir = dir + dir_inertia
        end
    end
    return placements
end

function generate_heightmap(x, y, w, h, s, inputs)
    local hmap = gen_hmap(x, y, w, h, s)
    return hmap
end

function generate_biome_parameters(x, y, w, h, s)
    local tempmap = Heightmap(w, h)
    tempmap.noiseSeed = SEED + 5324
    tempmap:noise({x, y}, 0.04*s, 6)
    tempmap:mul(0.5)
    tempmap:add(0.5)
    
    local hummap = Heightmap(w, h)
    hummap.noiseSeed = SEED + 953
    hummap:noise({x, y}, 0.04*s, 6)
    tempmap:pow(3)
    hummap:pow(3)

    local hmap = gen_hmap(x, y, w, h, s)
    return tempmap, hummap, hmap
end