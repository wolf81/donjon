--[[
    util.lua
    utility functions

    written by Wolfgang Schreurs <info+donjon@wolftrail.net>
--]]

function getKeys(tbl)
    local keys = {}

    for key, _ in pairs(tbl) do
        keys[#keys + 1] = key
    end

    return keys
end

function bitIsSet(v, b)
    return bit.band(v, b) == b
end