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
require(PATH .. '.direction')

local function printDungeon(dungeon)
    local s = ''
    for y = 0, dungeon.n_rows - 1 do
        for x = 0, dungeon.n_cols - 1 do
            local cell = dungeon.cell[y][x]
            if cell == 0 then
                s = s .. '.'
            elseif hasbit(cell, Cell.ENTRANCE) then
                s = s .. '+'
            elseif hasbit(cell, Cell.PERIMETER) then
                s = s .. '#'
            else
                s = s .. ' '
            end
        end
        s = s .. '\n'
    end
    print(s)
end

local connect = {}

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
            local cell = dungeon.cell[y][x]
            if hasbit(cell, Cell.BLOCKED) then 
                info.blocked = true
                return info
            end

            if hasbit(cell, Cell.ROOM) then
                local roomId = bit.rshift(bit.band(dungeon.cell[y][x], Cell.ROOM_ID), 6)
                local count = info[roomId] or 0
                info[roomId] = count + 1 
            end
        end
    end

    return info
end

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

            if hasbit(cell, Cell.ENTRANCE) then
                cell = bit.band(cell, bit.bnot(Cell.ESPACE))
            elseif hasbit(cell, Cell.PERIMETER) then
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

--[[
function check_sill(a, b, c, d, e) {
    var g = c + di[e],
        f = d + dj[e],
        h = a[g][f];
    if (!(h & PERIMETER)) return false;
    if (h & BLOCK_DOOR) return false;
    h = g + di[e];
    var i = f + dj[e];
    a = a[h][i];
    if (a & BLOCKED) return false;
    a = (a & ROOM_ID) >> 6;
    if (a == b.id) return false;
    return b = {
        sill_r: c,
        sill_c: d,
        dir: e,
        door_r: g,
        door_c: f,
        out_id: a
    }
}
]]

local function checkSill(dungeon, room, y, x, dir)
    local dx, dy = unpack(Direction[dir])
    local x1, y1 = x + dx, y + dy
    local cell = dungeon.cell[y1][x1]

    if not hasbit(cell, Cell.PERIMETER) then return false end
    if hasbit(cell, Cell.BLOCK_DOOR) then return false end

    local x2, y2 = x1 + dx, y1 + dy
    cell = dungeon.cell[y2][x2]

    if hasbit(cell, Cell.BLOCKED) then return false end
    local room_id = bit.rshift(bit.band(cell, Cell.ROOM_ID), 6)

    if room_id == room.id then return false end

    return {
        sill_r = y,
        sill_c = x,
        dir = dir,
        door_r = y1,
        door_c = x1,
        out_id = room_id > 0 and room.id or nil,
    }
end

local function doorSills(dungeon, room)
    local sills = {}

    if room.complex then
        error('not implemented')
    else
        local n, s, e, w = room.north, room.south, room.east, room.west

        if n >= 3 then
            for x = w, e, 2 do
                local sill = checkSill(dungeon, room, n, x, 'north')
                if sill then
                    sills[#sills + 1] = sill
                end
            end
        end

        if s <= dungeon.n_rows - 3 then
            for x = w, e, 2 do
                local sill = checkSill(dungeon, room, s, x, 'south')
                if sill then
                    sills[#sills + 1] = sill
                end
            end            
        end

        if w >= 3 then
            for y = n, s, 2 do
                local sill = checkSill(dungeon, room, y, w, 'west')
                if sill then
                    sills[#sills + 1] = sill
                end
            end                        
        end

        if e <= dungeon.n_cols - 3 then
            for y = n, s, 2 do
                local sill = checkSill(dungeon, room, y, e, 'east')
                if sill then
                    sills[#sills + 1] = sill
                end
            end                        
        end
    end

    print('sills', #sills)

    return sills
end

--[[
function alloc_opens(a, b) {
    a = (b.south - b.north) / 2 + 1;
    b = (b.east - b.west) / 2 + 1;
    b = Math.floor(Math.sqrt(b * a));
    return b = b + random(b)
}
]]
local function allocOpens(dungeon, room)
    local y = (room.south - room.north) / 2 + 1
    local x = (room.east - room.west) / 2 + 1
    local opens = math.floor(math.sqrt(x * y))
    return opens + prng.random(opens)
end

local function openDoor(dungeon, room, sill)
    local doors = Doors[dungeon.doors]
    print('open door')
    local dr = sill.door_r
    local dc = sill.door_c
    local sr = sill.sill_r
    local sc = sill.sill_c
    local out_id = sill.out_id

    local dx, dy = unpack(Direction[sill.dir])

    for i = 0, 2 do
        local y = sr + dy * i
        local x = sc + dx * i
        local cell = dungeon.cell[y][x] 
        dungeon.cell[y][x] = bit.band(cell, bit.bnot(Cell.PERIMETER))
        dungeon.cell[y][x] = bit.bor(cell, Cell.ENTRANCE)
        print('add entrance @ ' .. x .. '.' .. y)
    end

    return dungeon
end

local function openRoom(dungeon, room)
    local sills = doorSills(dungeon, room)
    if #sills == 0 then return dungeon end

    local n_open = allocOpens(dungeon, room)

    for i = 1, n_open do
        local sill = splice(sills, prng.random(#sills) + 1, 1)

        if not sill then break end

        local y = sill.door_r
        local x = sill.door_c

        local cell = dungeon.cell[y][x]
        if not hasbit(cell, Cell.DOORSPACE) then
            print('no doorspace')
            if sill.out_id then
                local ids = { sill.out_id, room.id }
                table.sort(ids)                
                ids = table.concat(ids, ',')

                if not connect[ids] then
                    dungeon = openDoor(dungeon, room, sill)
                    connect[ids] = true
                end
            else
                dungeon = openDoor(dungeon, room, sill)
            end
        end
    end

   return dungeon 
end

--[[
var d = a;
W = {};
let B;
for (B = 1; B <= d.n_rooms; B++) a: {
    let l;
    var g = d,
        c = d.room[B];
    let q = ca(g, c);
    if (!q.length) {
        d = g;
        break a
    } {
        let p = Math.floor(Math.sqrt(((c.east - c.west) / 2 + 1) * ((c.south - c.north) / 2 + 1)));
        var e = p + random(p)
    }
    let w = e;
    for (l = 0; l < w; l++) {
        let p = q.splice(random(q.length), 1).shift();
        if (!p) break;
        if (!(g.cell[p.door_r][p.door_c] & 4128768)) {
            let r;
            if (r = p.out_id) {
                let x = [c.id, r].sort(N).join(",");
                W[x] || (g = da(g, c, p), W[x] = 1)
            } else g = da(g, c, p)
        }
    }
    d = g
]]
local function openRooms(dungeon)
    connect = {}

    for i = 1, dungeon.n_rooms do
        print('open room ' .. i)
        dungeon = openRoom(dungeon, dungeon.room[i])
    end

    return dungeon
end

local function generate(params)
    local dungeon = init(params)

    dungeon = emplaceRooms(dungeon)
    dungeon = openRooms(dungeon)

    printDungeon(dungeon)

    return dungeon
end

return {
    generate = generate,
}

