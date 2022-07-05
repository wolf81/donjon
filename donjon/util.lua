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
        local v = table.remove(list, start)
        print('v', v)
        for k,v in pairs(v) do
            print(k,v)
            print()
        end
        removed[#removed + 1] = v

        count = count - 1
    end

    if #removed == 1 then
        return removed[1]
    end

    return removed
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
