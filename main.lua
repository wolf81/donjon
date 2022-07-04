io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local donjon = require 'donjon'
local prng = donjon.prng
local dungeon = donjon.dungeon

function love.load(args)
    print(donjon)

    local d = dungeon.generate({
        seed = 'a',
        dungeon_layout = 'rectangle',
        dungeon_size = 'dimin',
        room_layout = 'scattered',
        room_size = 'medium',
        corridor_layout = 'errant',
        remove_deadends = 'some',
        add_stairs = 'yes',
        doors = 'standard',
    })
    print(d)
end