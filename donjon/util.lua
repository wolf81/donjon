--[[
    util.lua
    utility functions

    written by Wolfgang Schreurs <info+donjon@wolftrail.net>
--]]

-- return a list of keys from a table
function getKeys(tbl)
    local keys = {}

    for key, _ in pairs(tbl) do
        keys[#keys + 1] = key
    end

    return keys
end

-- remove elements from a list
function splice(list, start, count)
    if count == nil then
        count = #list - start
    end

    while count > 0 do
        table.remove(list, start + 1)

        count = count - 1
    end
end

-- remove and return the first element from a list
function shift(list)
    return table.remove(list, 1)
end

-- bit manipulation functions: https://stackoverflow.com/a/263738/250164

-- check if a bit is set
function hasbit(v, b)
    return bit.band(v, b) == b
end

--[[
function clearbit(v, b)
    return bit.band(v, bit.bnot(b))
end
--]]
