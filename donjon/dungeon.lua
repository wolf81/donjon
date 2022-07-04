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
require(PATH .. '.flags')

local function printDungeon(dungeon)
    local s = ''
    for y = 0, dungeon.n_rows - 1 do
        for x = 0, dungeon.n_cols - 1 do
            local cell = dungeon.cell[y][x]
            if cell == 0 then
                s = s .. '.'
            elseif bitIsSet(cell, Cell.PERIMETER) then
                s = s .. '#'
            else
                s = s .. ' '
            end
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
            cell[y][x] = Cell.NOTHING
        end
    end

    local dungeon = {
        n_i = n_i,
        n_j = n_j,
        cell_size = d_size.cell,
        n_rows = n_rows,
        n_cols = n_cols,
        max_row = n_rows - 1,
        max_col = n_cols - 1,
        cell = cell,
    }

    for k, v in pairs(params) do
        dungeon[k] = v
    end

    prng.randomseed(dungeon.seed)

    print()
    for k, v in pairs(dungeon) do
        print(k, v)
    end
    print()

    return dungeon
end

-- allocate a room count
local function allocRooms(dungeon, room_size)
    local area = dungeon.n_cols * dungeon.n_rows
    local room_size = RoomSize[room_size or dungeon.room_size]
    local count = (room_size.size or 2) + (room_size.radix or 5) + 1
    count = 2 * math.floor(area / (count * count))
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

--[[
function emplace_room(a, b) {
    a = a;
    if (a.n_rooms == 999) return a;
    var c = b || {};
    c = set_room(a, c);
    b = c.i * 2 + 1;
    var d = c.j * 2 + 1,
        e = (c.i + c.height) * 2 - 1,
        g = (c.j + c.width) * 2 - 1;
    if (b < 1 || e > a.max_row) return a;
    if (d < 1 || g > a.max_col) return a;
    var f = sound_room(a, b, d, e, g);
    if (f.blocked) return a;

    f = $H(f).keys();
    var h = f.length;
    if (h == 0) {
        f = a.n_rooms + 1;
        a.n_rooms = f
    } else if (h == 1)
        if (a.complex_rooms) {
            f = f[0];
            if (f != c.complex_id) return a
        } else return a;
    else return a;

    for (h = b; h <= e; h++) {
        var i;
        for (i = d; i <= g; i++) {
            if (a.cell[h][i] & ENTRANCE) 
                a.cell[h][i] &= ~ESPACE;
            else if (a.cell[h][i] & PERIMETER) 
                a.cell[h][i] &= ~PERIMETER;

            a.cell[h][i] |= ROOM | f << 6
        }
    }
    h = (e - b + 1) * 10;
    i = (g - d + 1) * 10;
    c = {
        id: f,
        size: c.size,
        row: b,
        col: d,
        north: b,
        south: e,
        west: d,
        east: g,
        height: h,
        width: i,
        door: {
            north: [],
            south: [],
            west: [],
            east: []
        }
    };
    if (h = a.room[f])
        if (h.complex) h.complex.push(c);
        else {
            complex = {
                complex: [h, c]
            };
            a.room[f] = complex
        }
    else a.room[f] = c;
    for (h = b - 1; h <= e + 1; h++) {
        a.cell[h][d - 1] & (ROOM | ENTRANCE) || (a.cell[h][d - 1] |= PERIMETER);
        a.cell[h][g + 1] & (ROOM | ENTRANCE) || (a.cell[h][g + 1] |= PERIMETER)
    }
    for (i = d - 1; i <= g + 1; i++) {
        a.cell[b - 1][i] & (ROOM | ENTRANCE) || (a.cell[b - 1][i] |= PERIMETER);
        a.cell[e + 1][i] & (ROOM | ENTRANCE) || (a.cell[e + 1][i] |= PERIMETER)
    }
    return a
}

--]]

-- position room
local function setRoom(dungeon, room)
    room = room or {}

    local r_size = RoomSize[room.size or dungeon.room_size]
    local size = r_size.size or 2
    local radix = r_size.radix or 5

    room.size = size
    room.radix = radix

    if not room.height then
        if room.i then
            local i = math.max(dungeon.n_i - radix - room.i, 0)
            room.height = prng.random(i < radix and i or radix) + size
        else
            room.height = prng.random(radix) + size
        end
    end

    if not room.width then
        if room.j then
            local j = math.max(dungeon.n_j - randix - room.j, 0)
            room.width = prng.random(j < radix and j or radix) + size
        else
            room.width = prng.random(radix) + size
        end
    end

    if not room.i then room.i = prng.random(dungeon.n_i - room.height) end
    if not room.j then room.j = prng.random(dungeon.n_j - room.width) end

    return room
end

-- check if a room exists between x1, y1 and x2, y2
local function soundRoom(dungeon, x1, y1, x2, y2)
    local info = {}

    for x = x1, x2 do
        for y = y1, y2 do
            if bit.band(dungeon.cell[y][x], Cell.BLOCKED) == Cell.BLOCKED then
                info.blocked = true
                return info
            end

            if bit.band(dungeon.cell[y][x], Cell.ROOM) == Cell.ROOM then
                local roomId = bit.rshift(bit.band(dungeon.cell[y][x], Cell.ROOM_ID), 6)
                local count = info[roomId] or 0
                info[roomId] = count + 1 
            end
        end
    end

    return info
end

--[[
function emplace_room(a, b) {
    a = a;
    if (a.n_rooms == 999) return a;
    var c = b || {};
    c = set_room(a, c);
    b = c.i * 2 + 1;
    var d = c.j * 2 + 1,
        e = (c.i + c.height) * 2 - 1,
        g = (c.j + c.width) * 2 - 1;
    if (b < 1 || e > a.max_row) return a;
    if (d < 1 || g > a.max_col) return a;
    var f = sound_room(a, b, d, e, g);
    if (f.blocked) return a;

    f = $H(f).keys();
    var h = f.length;
    if (h == 0) {
        f = a.n_rooms + 1;
        a.n_rooms = f
    } else if (h == 1)
        if (a.complex_rooms) {
            f = f[0];
            if (f != c.complex_id) return a
        } else return a;
    else return a;

    for (h = b; h <= e; h++) {
        var i;
        for (i = d; i <= g; i++) {
            if (a.cell[h][i] & ENTRANCE) 
                a.cell[h][i] &= ~ESPACE;
            else if (a.cell[h][i] & PERIMETER) 
                a.cell[h][i] &= ~PERIMETER;

            a.cell[h][i] |= ROOM | f << 6
        }
    }
    h = (e - b + 1) * 10;
    i = (g - d + 1) * 10;
    c = {
        id: f,
        size: c.size,
        row: b,
        col: d,
        north: b,
        south: e,
        west: d,
        east: g,
        height: h,
        width: i,
        door: {
            north: [],
            south: [],
            west: [],
            east: []
        }
    };
    if (h = a.room[f])
        if (h.complex) h.complex.push(c);
        else {
            complex = {
                complex: [h, c]
            };
            a.room[f] = complex
        }
    else a.room[f] = c;
    for (h = b - 1; h <= e + 1; h++) {
        a.cell[h][d - 1] & (ROOM | ENTRANCE) || (a.cell[h][d - 1] |= PERIMETER);
        a.cell[h][g + 1] & (ROOM | ENTRANCE) || (a.cell[h][g + 1] |= PERIMETER)
    }
    for (i = d - 1; i <= g + 1; i++) {
        a.cell[b - 1][i] & (ROOM | ENTRANCE) || (a.cell[b - 1][i] |= PERIMETER);
        a.cell[e + 1][i] & (ROOM | ENTRANCE) || (a.cell[e + 1][i] |= PERIMETER)
    }
    return a
}
]]

-- add a room
local function emplaceRoom(dungeon, room)
    if dungeon.n_rooms == 999 then return dungeon end

    local room = setRoom(dungeon, room)

    local y1 = room.i * 2 + 1
    local x1 = room.j * 2 + 1
    local y2 = (room.i + room.height) * 2 - 1
    local x2 = (room.j + room.width) * 2 - 1

    if y1 < 1 or y2 > dungeon.max_row then return dungeon end
    if x1 < 1 or x2 > dungeon.max_col then return dungeon end

    local info = soundRoom(dungeon, x1, y1, x2, y2)
    if info.blocked then return dungeon end

    local keys = getKeys(info)
    local room_id = nil
    local n_keys = #keys
    if n_keys == 0 then
        room_id = dungeon.n_rooms + 1
        dungeon.n_rooms = room_id
    elseif n_keys == 1 then
        if dungeon.complex_rooms then
            room_id = keys[1]
            if roomId ~= room.complex_id then return dungeon end
        else
            return dungeon
        end
    else
        return dungeon
    end

    print('ROOM ' .. room_id .. ' (' .. x1 .. ', ' .. y1 .. ', ' .. x2 .. ', ' .. y2 .. ')')

    for x = x1, x2 do
        for y = y1, y2 do
            local cell = dungeon.cell[y][x]

            if bit.band(cell, Cell.ENTRANCE) then
                cell = bit.band(cell, bit.bnot(Cell.ESPACE))
            elseif bit.band(cell, Cell.PERIMETER) then
                cell = bit.band(cell, bit.bnot(Cell.PERIMETER))
            end

            dungeon.cell[y][x] = bit.bor(cell, bit.bor(Cell.ROOM, bit.lshift(room_id, 6)))
        end
    end

    room = {
        id = room_id,
        size = room.size,
        row = y1,
        col = x1,
        north = y1,
        south = y2,
        west = x1,
        east = x2,
        height = 10 * (y2 - y1 + 1),
        width = 10 * (x2 - x1 + 1),
        door = {
            north = {},
            south = {},
            east = {},
            west = {},
        }
    }

    local d_room = dungeon.room[room_id]
    if d_room then
        if d_room.complex then
            table.insert(dungeon.room[room_id].complex, room)
        else
            print('add complex room')
            dungeon.room[room_id] = {
                complex = { d_room, room }
            }
        end
    else
        dungeon.room[room_id] = room
    end

    local room_entrance = bit.bor(Cell.ROOM, Cell.ENTRANCE)
    for x = x1 - 1, x2 + 1 do 
        local cell = dungeon.cell[y1 - 1][x]    
        if bit.band(cell, room_entrance) then
            dungeon.cell[y1 - 1][x] = bit.bor(cell, Cell.PERIMETER)
        end

        local cell = dungeon.cell[y2 + 1][x]    
        if bit.band(cell, room_entrance) then
            dungeon.cell[y2 + 1][x] = bit.bor(cell, Cell.PERIMETER)            
        end
    end

    for y = y1 - 1, y2 + 1 do 
        local cell = dungeon.cell[y][x1 - 1]
        if bit.band(cell, room_entrance) then
            dungeon.cell[y][x1 - 1] = bit.bor(cell, Cell.PERIMETER)
        end

        local cell = dungeon.cell[y][x2 + 1]
        if bit.band(cell, room_entrance) == 0 then
            dungeon.cell[y][x2 + 1] = bit.bor(cell, Cell.PERIMETER)            
        end
    end

    return dungeon
end

local function emplaceRooms(dungeon)
    local r_size = RoomSize[dungeon.room_size]
    local r_layout = RoomLayout[dungeon.room_layout]

    dungeon.huge_rooms = r_size.huge or false
    dungeon.complex_rooms = r_layout.complex or false
    dungeon.n_rooms = 0
    dungeon.room = {}

    if r_layout == RoomLayout.dense then
        error('not implemented')
    else
        local room_count = allocRooms(dungeon)

        for i = 0, room_count do
            local room = emplaceRoom(dungeon)
        end

        if dungeon.huge_rooms then
            error('not implemented')
        end
    end

    print()

    return dungeon
end

local function generate(params)
    local dungeon = init(params)

    dungeon = emplaceRooms(dungeon)

    printDungeon(dungeon)

    return dungeon
end

return {
    generate = generate,
}

