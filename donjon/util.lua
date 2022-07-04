function getKeys(tbl)
    local keys = {}

    for key, _ in pairs(tbl) do
        keys[#keys + 1] = key
    end

    return keys
end
