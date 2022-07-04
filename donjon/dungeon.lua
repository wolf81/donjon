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
    local d_layout = DungeonLayout[params.dungeon_layout]
    local d_size = DungeonSize[params.dungeon_size]

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

    local dungeon = {
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
    for k, v in pairs(dungeon) do
        print(k, v)
    end
    print()

    printDungeon(dungeon)

    return dungeon
end

--[[
    var b = get_dc("room_size", a),
        c = get_dc("room_layout", a);
    a.huge_rooms = b.huge;
    a.complex_rooms = c.complex;
    a.n_rooms = 0;
    a.room = [];
    return a = a.room_layout == "dense" ? dense_rooms(a) : scatter_rooms(a)
--]]


--[[
    function ba(a, b) {
        b = J.room_size[b || a.room_size];
        b = (b.size || 2) + (b.radix || 5) + 1;
        b = 2 * Math.floor(a.n_cols * a.n_rows / (b * b));
        "sparse" == a.room_layout && (b /= 13);
        return b
    }
]]

--[[
function alloc_rooms(a, b) {
    a = a;
    var c = b || a.room_size;
    b = a.n_cols * a.n_rows;
    var d = dc.room_size[c];
    c = d.size || 2;
    d = d.radix || 5;
    c = c + d + 1;
    c = c * c;
    b = Math.floor(b / c) * 2;
    if (a.room_layout == "sparse") b /= 13;
    return b
}
]]
local function allocRooms(dungeon, params, room_size)
    local layout = RoomLayout[params.room_layout]

    local area = dungeon.n_cols * dungeon.n_rows
    local r_size = RoomSize[room_size or params.room_size]
    local s = r_size.size or 2
    local r = r_size.radix or 5
    size = size + radix + 1
    size = size * size
    local count = math.floor(area / size) * 2
    
    if layout == RoomLayout.sparse then
        count = math.floor(count / 13)
    end

    return count
end

--[[
local function denseRooms(dungeon, params)
end

local function scatterRooms(dungeon, params)
end
--]]

local function emplaceRoom(dungeon, params)
    error('not implemented')
end

local function emplaceRooms(dungeon, params)
    local r_size = RoomSize[params.room_size]
    local r_layout = RoomLayout[params.room_layout]

    dungeon.huge_rooms = r_size.huge or false
    dungeon.complex_rooms = r_layout.complex or false
    dungeon.n_rooms = 0
    dungeon.room = {}

    if r_layout == RoomLayout.dense then
        error('not implemented')
    else
        local room_count = allocRooms(dungeon, params)
        print('make #' .. room_count .. ' rooms')

        for i = 0, room_count do
            local room = emplaceRoom(dungeon, params)
        end

        if dungeon.huge_rooms then
            error('not implemented')
        end
    end

    print('r', r_size, r_layout)

    return dungeon
end

local function generate(params)
    local dungeon = init(params)

    dungeon = emplaceRooms(dungeon, params)

    return dungeon
end

return {
    generate = generate,
}

