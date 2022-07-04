local donjon = require 'donjon'
local prng = donjon.prng

function love.load(args)
    print(donjon)

    prng.randomseed('Dungeon of fiery death!')
    local v = prng.random(13442)
    print(v)

    for i = 1, 100 do
        print(prng.random())
    end
end