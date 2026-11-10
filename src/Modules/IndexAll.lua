local function GetAll(tbl, target)
    local results = {}

    local function Search(current)
        for key, value in pairs(current) do
            if key == target then
                table.insert(results, {
                    [key] = value
                })
            end

            if type(value) == "table" then
                Search(value)
            end
        end
    end

    Search(tbl)

    return results
end

return GetAll