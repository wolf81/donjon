--[[
    config.lua
    configuration options for the dungeon generator

    written by Wolfgang Schreurs <info+donjon@wolftrail.net>
    based on code from drow <drow@bin.sh>
--]]

local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.flags')

DungeonSize = {
    fine = { size = 200, cell = 18 },
    tiny = { size = 318, cell = 18 },
    dimin = { size = 252, cell = 18 },  
    small = { size = 400, cell = 18 },
    medium = { size = 504, cell = 18 },  
    large = { size = 635, cell = 18 },
    huge = { size = 800, cell = 18 },
    gargant = { size = 1008, cell = 18 },
    colossal = { size = 1270, cell = 18 },
}

DungeonLayout = {
    square = { aspect = 1.0 },
    rectangle = { aspect = 1.3 },
    box = { 
        aspect = 1, 
        mask = { 
            { 1, 1, 1 }, 
            { 1, 0, 1 }, 
            { 1, 1, 1 },
        }
    },
    cross = { 
        aspect = 1.0, 
        mask = {
            { 0, 1, 0 },
            { 1, 1, 1 },
            { 0, 1, 0 },
        }
    },
    dagger = {
        aspect = 1.3,
        mask = {
            { 0, 1, 0 },
            { 1, 1, 1 },
            { 0, 1, 0 },
            { 0, 1, 0 },
        }
    },
    saltire = {
        aspect = 1.0,
    },
    keep = {
        aspect = 1.0,
        mask = {
            { 1, 1, 0, 0, 1, 1 },
            { 1, 1, 1, 1, 1, 1 },
            { 0, 1, 1, 1, 1, 0 },
            { 0, 1, 1, 1, 1, 0 },
            { 1, 1, 1, 1, 1, 1 },
            { 1, 1, 0, 0, 1, 1 },
        }
    },
    hexagon = {
        aspect = 0.9
    },
    round = {
        aspect = 1.0
    }
}

RoomSize = {
    small = { size = 2, radix = 2, huge = false },
    medium = { size = 2, radix = 5, huge = false },
    large = { size = 5, radix = 2, huge = false },
    huge = { size = 5, radix = 5, huge = true },
    gargant = { size = 8, radix = 5, huge = true },
    colossal = { size = 8, radix = 8, huge = true },
}

RoomLayout = {
    sparse = {},
    scattered = {},
    dense = {},
}

CorridorLayout = {
    labyrinth = { pct = 0 },
    errant = { pct = 50 },
    straight = { pct = 90 },
}

RemoveDeadends = {
    none = { pct = 0 },
    some = { pct = 50 },
    all = { pct = 100 },
}

AddStairs = {
    no = {},
    yes = {},
    many = {},
}

Doors = {
    none = { 
        ['01-15'] = Cell.ARCH,
    },
    basic = { 
        ['01-15'] = Cell.ARCH,
        ['16-60'] = Cell.DOOR,        
    },
    secure = { 
        ['01-15'] = Cell.ARCH,
        ['16-60'] = Cell.DOOR,
        ['61-75'] = Cell.LOCKED,
    },
    standard = { 
        ['01-15'] = Cell.ARCH,
        ['16-60'] = Cell.DOOR,
        ['61-75'] = Cell.LOCKED,
        ['76-90'] = Cell.TRAPPED,
        ['91-100'] = Cell.SECRET,
        ['101-110'] = Cell.PORTC,
    },
    deathtrap = {
        ['01-15'] = Cell.ARCH,
        ['16-30'] = Cell.TRAPPED,
        ['31-40'] = Cell.SECRET,
    },
}
