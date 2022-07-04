Cell = {
    NOTHING     = 0x0,
    BLOCKED     = 0x1,
    ROOM        = 0x2,
    CORRIDOR    = 0x4,
    PERIMETER   = 0x10,
    ENTRANCE    = 0x20,    
    ROOM_ID     = 0xFFC0,

    ARCH        = 0x10000,
    DOOR        = 0x20000,
    LOCKED      = 0x40000,
    TRAPPED     = 0x80000,
    SECRET      = 0x100000,
    PORTC       = 0x200000,

    STAIR_DN    = 0x400000,
    STAIR_UP    = 0x800000,

    LABEL       = 0xFF000000,
}

Cell.OPENSPACE = bit.bor(Cell.ROOM, Cell.CORRIDOR)
Cell.DOORSPACE = bit.bor(Cell.ARCH, Cell.DOOR, Cell.LOCKED, Cell.TRAPPED, Cell.SECRET, Cell.PORTC)
Cell.ESPACE = bit.bor(Cell.ENTRANCE, Cell.DOORSPACE, Cell.LABEL)
Cell.STAIRS = bit.bor(Cell.STAIR_DN, Cell.STAIR_UP)
Cell.BLOCK_ROOM = bit.bor(Cell.BLOCKED, Cell.ROOM)
Cell.BLOCK_CORR = bit.bor(Cell.BLOCKED, Cell.PERIMETER, Cell.CORRIDOR)
Cell.BLOCK_DOOR = bit.bor(Cell.BLOCKED, Cell.DOORSPACE)
