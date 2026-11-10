local function PrintTable(tbl, indent)
    indent = indent or 0

    for key, value in pairs(tbl) do
        local spacing = string.rep("  ", indent)

        if type(value) == "table" then
            print(spacing .. tostring(key) .. " = {")
            PrintTable(value, indent + 1)
            print(spacing .. "}")
        else
            print(spacing .. tostring(key) .. " = " .. tostring(value))
        end
    end
end

return PrintTable