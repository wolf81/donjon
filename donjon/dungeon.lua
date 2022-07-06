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
require(PATH .. '.stair_end')

local function keyRange(str)
    -- range up to 100, e.g. '65-00' => 65, 100
    local a, b = string.match(str, '(%d+)-00'), nil
    if a then return tonumber(a, 10), 100 end

    -- range under 100, e.g. '65-75' => 65, 75
    a, b = string.match(str, '(%d+)-(%d+)')
    if a and b then return tonumber(a, 10), tonumber(b, 10) end

    -- range of value 100, e.g. '00' => 100, 100
    if str == '00' then return 100, 100 end

    -- range of single value under 100, e.g. '15' => 15, 15
    return tonumber(str, 10), tonumber(str, 10)
end

-- process each key in a table
-- retrieve the key range (e.g. '01-35', '36-45', '46-60')
-- return the highest value from all key ranges, so in this example: 60
local function scaleTable(tbl)
    local c = 0

    for str, _ in pairs(tbl) do
        local _, b = keyRange(str)
        if b > c then c = b end
    end

    return c
end

local function selectFromList(list)
    return list[prng.random(#list)]
end

local function selectFromTable(tbl)
    local scale = scaleTable(tbl)
    scale = prng.random(scale)
    for key, _ in pairs(tbl) do
        local a, b = keyRange(key)
        if scale >= a and scale <= b then return tbl[key] end
    end
    return nil
end

local function selectFrom(tbl)
    if isArray(tbl) then
        return selectFromList(tbl)
    else
        return selectFromTable(tbl)
    end
end

local function printDungeon(dungeon)
    local s = ''
    for y = 0, dungeon.n_rows - 1 do
        for x = 0, dungeon.n_cols - 1 do
            local cell = dungeon.cell[y][x]

            if hasmask(cell, Cell.DOORSPACE) then
                s = s .. '+'
            elseif hasbit(cell, Cell.PERIMETER) then
                s = s .. '#'
            elseif hasmask(cell, Cell.STAIRS) then
                if hasbit(cell, Cell.STAIR_DN) then
                    s = s .. '<'
                else
                    s = s .. '>'
                end
            elseif hasbit(cell, Cell.ROOM) then
                local c = bit.band(bit.rshift(cell, 24), 0xFF)
                s = s .. (c ~= 0 and string.char(c) or '.')
            elseif hasbit(cell, Cell.CORRIDOR) then
                s = s .. '.'
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
            room.height = prng.random(0, i < radix and i or radix) + size
        else
            room.height = prng.random(0, radix) + size
        end
    end

    if not room.width then
        if room.j then
            local j = math.max(dungeon.n_j - randix - room.j, 0)
            room.width = prng.random(0, j < radix and j or radix) + size
        else
            room.width = prng.random(0, radix) + size
        end
    end

    if not room.i then room.i = prng.random(0, dungeon.n_i - room.height) end
    if not room.j then room.j = prng.random(0, dungeon.n_j - room.width) end

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

local function shuffle(list)
    for i = #list, 1, -1 do
        -- a bit hacky to use ceil() here, but prng random needs to support 
        -- random(min, max) in order to fix properly
        local j = prng.random(i)
        local dir1, dir2 = list[i], list[j]
        list[j] = dir1
        list[i] = dir2
    end

    return list
end

local function tunnelDirs(dungeon, dir)
    local dirs = shuffle({ Direction.north, Direction.south, Direction.east, Direction.west })

    if dir then
        if dungeon.straight_pct and (prng.random(100) < dungeon.straight_pct) then
            table.insert(dirs, 1, dir)
        end
    end

    return dirs    
end

local function delveTunnel(dungeon, y1, x1, y2, x2)
    local y_range = { y1, y2 }
    table.sort(y_range)

    local x_range = { x1, x2 }
    table.sort(x_range)

    for y = y_range[1], y_range[2] do
        for x = x_range[1], x_range[2] do
            dungeon.cell[y][x] = bit.band(dungeon.cell[y][x], bit.bnot(Cell.ENTRANCE))
            dungeon.cell[y][x] = bit.bor(dungeon.cell[y][x], Cell.CORRIDOR)
        end
    end

    return true
end

local function soundTunnel(dungeon, y1, x1, y2, x2)
    if y2 < 0 or y2 > dungeon.n_rows then return false end
    if x2 < 0 or x2 > dungeon.n_cols then return false end

    local y_range = { y1, y2 }
    table.sort(y_range)

    local x_range = { x1, x2 }
    table.sort(x_range)

    for y = y_range[1], y_range[2] do
        for x = x_range[1], x_range[2] do
            if hasmask(dungeon.cell[y][x], Cell.BLOCK_CORR) then return false end
        end
    end

    return true
end

local function openTunnel(dungeon, y, x, dir)
    local y1 = y * 2 + 1
    local x1 = x * 2 + 1
    local dx, dy = unpack(dir)
    local y2 = (y + dy) * 2 + 1
    local x2 = (x + dx) * 2 + 1
    local y_mid = (y1 + y2) / 2
    local x_mid = (x1 + x2) / 2

    if soundTunnel(dungeon, y_mid, x_mid, y2, x2) then
        return delveTunnel(dungeon, y1, x1, y2, x2)
    end

    return false
end

local function tunnel(dungeon, y, x, last_dir)
    local dirs = tunnelDirs(dungeon, last_dir)

    for _, dir in ipairs(dirs) do
        if openTunnel(dungeon, y, x, dir) then
            local dx, dy = unpack(dir)
            dungeon = tunnel(dungeon, y + dy, x + dx, dir)
        end
    end

    return dungeon
end

local function corridors(dungeon)
    local layout = CorridorLayout[dungeon.corridor_layout]
    dungeon.straight_pct = layout.pct

    for i = 1, dungeon.n_i - 1 do
        local y = i * 2 + 1

        for j = 1, dungeon.n_j - 1 do
            local x = j * 2 + 1
            if bit.band(dungeon.cell[y][x], Cell.CORRIDOR) == 0 then
                dungeon = tunnel(dungeon, i, j)
            end
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
    if hasmask(cell, Cell.BLOCK_DOOR) then return false end

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
    return opens + prng.random(0, opens)
end

local function openDoor(dungeon, room, sill)
    local dr = sill.door_r
    local dc = sill.door_c
    local sr = sill.sill_r
    local sc = sill.sill_c
    local out_id = sill.out_id
    local dir = sill.dir

    local dx, dy = unpack(Direction[sill.dir])

    for i = 0, 2 do
        local y = sr + dy * i
        local x = sc + dx * i
        local cell = dungeon.cell[y][x] 
        dungeon.cell[y][x] = bit.band(cell, bit.bnot(Cell.PERIMETER))
        dungeon.cell[y][x] = bit.bor(cell, Cell.ENTRANCE)
    end

    local door = selectFromTable(Doors[dungeon.doors])

    local d_info = {
        row = dr,
        col = dc,
        out_id = out_id,
    }

    local cell = dungeon.cell[dr][dc]

    dungeon.cell[dr][dc] = bit.bor(cell, door)
    
    if door == Cell.ARCH then
        d_info.key = 'arch'
        d_info.type = 'Archway'
    elseif door == Cell.DOOR then        
        d_info.key = 'open'
        d_info.type = 'Unlocked Door'
    elseif door == Cell.LOCKED then
        d_info.key = 'lock'
        d_info.type = 'Locked Door'
    elseif door == Cell.TRAPPED then
        d_info.key = 'lock'
        d_info.type = 'Locked Door'
    elseif door == Cell.SECRET then
        d_info.key = 'secret'
        d_info.type = 'Secret Door'
    elseif door == Cell.PORTC then
        d_info.key = 'portc'
        d_info.type = 'Portcullis'        
    end

    local doors = room.door[dir] or {}
    doors[#doors + 1] = d_info
    room.doors = doors

    room.last_door = d_info

    return dungeon
end

local function labelRooms(dungeon, room)
    for i = 1, dungeon.n_rooms do
        local room = dungeon.room[i]
        local room_id = tostring(room.id)
        local len = #room_id
        local y = math.floor((room.north + room.south) / 2)
        local x = math.floor((room.west + room.east - len) / 2) + 1

        for f = 1, len do
            local cell = dungeon.cell[y][x + f - 1]
            local char = string.byte(string.sub(room_id, f, f))
            char = bit.lshift(char, 24)
            dungeon.cell[y][x + f - 1] = bit.bor(cell, char)
        end
    end

    return dungeon
end

local function openRoom(dungeon, room)
    local sills = doorSills(dungeon, room)
    if #sills == 0 then return dungeon end

    local n_open = allocOpens(dungeon, room)

    for i = 1, n_open do
        local sill = splice(sills, prng.random(#sills), 1)

        if not sill then break end

        local y = sill.door_r
        local x = sill.door_c

        local cell = dungeon.cell[y][x]
        if hasmask(cell, Cell.DOORSPACE) ~= 0 then
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
        dungeon = openRoom(dungeon, dungeon.room[i])
    end

    return dungeon
end

local function checkTunnel(cell, y, x, stair_end)
    if stair_end.corridor then
        for _, dyx in ipairs(stair_end.corridor) do
            local dy, dx = unpack(dyx)
            if cell[y + dy] then
                if cell[y + dy][x + dx] ~= Cell.CORRIDOR then
                    return false
                end
            end
        end
    end

    if stair_end.walled then
        for _, dyx in ipairs(stair_end.walled) do
            local dy, dx = unpack(dyx)
            if cell[y + dy] then
                if hasmask(cell[y + dy][x + dx], Cell.OPENSPACE) then
                    return false
                end
            end
        end
    end

    return true
end

local function stairEnds(dungeon)
    local cell = dungeon.cell
    local stair_ends = {}

    for i = 0, dungeon.n_i - 1 do
        local y = i * 2 + 1
        for j = 0, dungeon.n_j - 1 do
            local x = j * 2 + 1
            if dungeon.cell[y][x] == Cell.CORRIDOR then
                if not hasmask(dungeon.cell[y][x], Cell.STAIRS) then
                    local dirs = getKeys(StairEnd)
                    for _, dir in ipairs(dirs) do
                        if checkTunnel(dungeon, y, x, StairEnd[dir]) then
                            local stair_end = {
                                row = y,
                                col = x,
                                dir = dir,
                            }
                            dy, dx = unpack(StairEnd[dir].next)
                            stair_end.next_row = y + dy
                            stair_end.next_col = x + dx
                            stair_ends[#stair_ends + 1] = stair_end
                        end
                    end
                end
            end
        end
    end

    return stair_ends
end

local function allocStairs(dungeon)
    local count = 0

    if dungeon.add_stairs == 'many' then
        local area = dungeon.n_cols * dungeon.n_rows
        count = 3 + prng.random(0, math.floor(area / 1000))
    elseif dungeon.add_stairs == 'yes' then
        count = 2
    end

    return count
end

local function emplaceStairs(dungeon)
    local stair_ends = stairEnds(dungeon)
    if #stair_ends == 0 then return dungeon end    

    local n_stairs = allocStairs(dungeon)
    if n_stairs == 0 then return dungeon end

    local stairs = {}

    for i = 1, n_stairs do
        local stair = splice(stair_ends, prng.random(#stair_ends), 1)
        if not stair then break end

        local y, x = stair.row, stair.col
        
        local dir = i < 3 and i or math.random(2)
        if i == 1 then
            dungeon.cell[y][x] = bit.bor(dungeon.cell[y][x], Cell.STAIR_DN)
            stair.key = 'down'
        else
            dungeon.cell[y][x] = bit.bor(dungeon.cell[y][x], Cell.STAIR_UP)
            stair.key = 'up'
        end
        stairs[#stairs + 1] = stair
    end

    return dungeon
end

--[[
    var b = a.cell,
        c;
    for (c = 0; c <= a.n_rows; c++) {
        var d;
        for (d = 0; d <= a.n_cols; d++)
            if (b[c][d] & BLOCKED) b[c][d] = NOTHING
    }
    a.cell = b;
    return a
]]

local function clearBlocked(dungeon)
    for y = 0, dungeon.n_rows - 1 do
        for x = 0, dungeon.n_cols - 1 do
            if hasbit(dungeon.cell[y][x], Cell.BLOCKED) then
                dungeon.cell[y][x] = Cell.NOTHING
            end
        end
    end

    return dungeon
end


-- TODO: properly test this code
-- I am not sure in which cases the doors actually get fixed. Perhaps this 
-- would occur in a dense dungeon or a dungeon with complex rooms ...
local function fixDoors(dungeon)    
    local fixed = {}
    local fixed_doors = {}

    for _, room in ipairs(dungeon.room) do
        local dirs = getKeys(room.door)

        for _, dir in ipairs(dirs) do
            local dir_doors = {}

            for _, door in ipairs(room.door[dir]) do
                local y, x = door.row, door.col
                if hasmask(dungeon.cell[y][x], Cell.OPENSPACE) then
                    error('validate')

                    local door_pos = y .. ',' .. x
                    if fixed[door_pos] then
                        dir_doors[#dir_doors + 1] = door
                    else
                        local out_id = door.out_id
                        if out_id then
                            local out_room = dungeon.room[out_id]
                            local out_dir = Direction.opposite(dir)
                            door.out_id = {
                                room_id = out_id,
                                out_id = room_id,
                            }
                            table.insert(dungeon.room[out_id].door[out_dir], door)
                        end

                        dir_doors[#dir_doors + 1] = door
                        fixed[door_pos] = true
                    end
                end

                if #dir_doors > 0 then
                    room.door[dir] = fixed
                    concat(fixed_doors, fixed)
                else
                    room.door[dir] = {}
                end
            end
        end
    end

    return dungeon
end

local function cleanup(dungeon)
    if dungeon.remove_deadends then
        print('remove deadends')
    end

    if dungeon.close_args then
        print('close arcs')
    end

    dungeon = fixDoors(dungeon)
    dungeon = clearBlocked(dungeon)

    return dungeon
end

local function generate(params)
    local dungeon = init(params)

    dungeon = emplaceRooms(dungeon)
    dungeon = openRooms(dungeon)
    dungeon = labelRooms(dungeon)
    dungeon = corridors(dungeon)

    if dungeon.add_stairs then
        dungeon = emplaceStairs(dungeon)
    end

    dungeon = cleanup(dungeon)

    printDungeon(dungeon)

    return dungeon
end

return {
    generate = generate,
}

