--[[
    prng.lua
    seeded pseudo-random number generator 

    written by Wolfgang Schreurs <info+donjon@wolftrail.net>
    based on code from drow <drow@bin.sh>
--]]

-- the initial seed is always set to 1
local seed = 1

-- the maximum number used to calculate float values
local FLOAT_INT_MAX = 0x8000

local random_i = function(max)
    -- force use of 64 bit numbers here by using hex constants and ULL 
    -- annotation, to prevent loss of precision, in line with JavaScript code
    seed = 0x41C64E6D * seed + 0x3039
    seed = bit.band(seed, 0x7FFFFFFF)
    seed = bit.rshift(seed, 8) % max

    return seed
end

-- generate a random number
local random = function(max)
    max = max or 1

    if 1 < max then 
        -- for values greater or equal to 1, return an integer
        return random_i(max)
    else
        -- otherwise return a float 
        return random_i(FLOAT_INT_MAX) / FLOAT_INT_MAX
    end
end

-- compute a seed from a string
local computeSeed = function(str)
    local s = 42
    for i = 1, #str do
        local char = string.sub(str, i, i)
        s = bit.lshift(s, 0x5) - s + string.byte(char)
        s = bit.band(s, 0x7FFFFFFF)
    end
    return s
end

-- seed the random number generator with a number, string or if no argument
-- is provided, with an integer based on time
-- this function will also return the seed
local randomseed = function(s)
    local seed_type = type(s)
    if seed_type == 'number' then
        seed = math.floor(s)
    elseif seed_type == 'string' then
        seed = computeSeed(s)
    elseif s == nil then
        seed = os.time()
    else
        error('invalid argument, provide a number, string or no argument')
    end

    return seed
end

-- the module
return {
    random = random,
    randomseed = randomseed,
}
