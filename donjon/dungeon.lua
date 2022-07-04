--[[
    dungeon.lua
    random dungeon generator

    written by Wolfgang Schreurs <info+donjon@wolftrail.net>
    based on code from drow <drow@bin.sh>
--]]

local PATH = (...):match("(.-)[^%.]+$") 
local prng = require(PATH .. '.prng')

require(PATH .. '.config')
require(PATH .. '.util')

local function printDungeon(dungeon)
    local s = ''
    for y = 0, dungeon.n_rows - 1 do
        for x = 0, dungeon.n_cols - 1 do
            s = s .. dungeon.cell[y][x]
        end
        s = s .. '\n'
    end
    print(s)
end

local function init(params)
    local d_layout = DungeonLayout['rectangle']
    local d_size = DungeonSize['medium']

    local n_i = math.floor(d_size.size * d_layout.aspect / d_size.cell)
    local n_rows = 2 * n_i

    local n_j = math.floor(d_size.size / d_size.cell)
    local n_cols = 2 * n_j

    local cell = {}
    for y = 0, n_rows - 1 do
        cell[y] = {}

        for x = 0, n_cols - 1 do
            cell[y][x] = 0
        end
    end

    local d = {
        seed = prng.randomseed('Dungeon of fiery death!'),
        n_i = n_i,
        n_j = n_j,
        cell_size = d_size.cell,
        n_rows = n_rows,
        n_cols = n_cols,
        max_row = n_rows - 1,
        max_col = n_cols - 1,
        cell = cell,
    }

    print()
    for k, v in pairs(d) do
        print(k, v)
    end
    print()

    printDungeon(d)

    return d
end

local function emplaceRooms(dungeon)
    return dungeon
end

local function generate()
    local d = init()

    d = emplaceRooms(dungeon)

    return d
end

return {
    generate = generate,
}

