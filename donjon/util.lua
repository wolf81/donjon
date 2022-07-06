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

-- remove and return elements from a list
function splice(list, start, count)
    if count == nil then
        count = #list - start
    end

    local removed = {}

    while count > 0 do
        removed[#removed + 1] = table.remove(list, start)
        count = count - 1
    end

    if #removed == 1 then
        return removed[1]
    end

    return removed
end

-- adds items from second list to the first list
function concat(list1, list2)
    for _, item in ipairs(list2) do
        list1[#list1 + 1] = item
    end
end

-- bit manipulation functions: https://stackoverflow.com/a/263738/250164

-- check if a bit is set
function hasbit(v, b)
    return bit.band(v, b) == b
end

function hasmask(v, b)
    return bit.band(v, b) ~= 0
end

-- just an extremely basic method to check if a table is a list 
-- will not be correct in all situations
function isArray(tbl)
    if #tbl == 0 then return true end

    if tbl[1] == nil then return false end

    return true
end

--[[
function clearbit(v, b)
    return bit.band(v, bit.bnot(b))
end
--]]
