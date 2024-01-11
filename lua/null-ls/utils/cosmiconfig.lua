local u = require("null-ls.utils")

-- Create the default root_pattern for tools using cosmiconfig.
-- https://github.com/cosmiconfig/cosmiconfig#usage-for-end-users
---@param module_name string The module name.
return function(module_name)
    local patterns = {
        "package.json",
        ".{NAME}rc",
        ".{NAME}rc.json",
        ".{NAME}rc.yaml",
        ".{NAME}rc.yml",
        ".{NAME}rc.js",
        ".{NAME}rc.ts",
        ".{NAME}rc.cjs",
        "{NAME}.config.js",
        "{NAME}.config.ts",
        "{NAME}.config.mjs",
        "{NAME}.config.cjs",
    }
    for i, v in ipairs(patterns) do
        patterns[i] = string.gsub(v, "{NAME}", module_name)
    end

    return u.root_pattern(unpack(patterns))
end
