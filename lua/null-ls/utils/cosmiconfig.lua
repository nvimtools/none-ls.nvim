local u = require("null-ls.utils")

-- Create the default root_pattern for tools using cosmiconfig.
-- https://github.com/cosmiconfig/cosmiconfig#usage-for-end-users
---@param module_name string The module name.
---@param pkg_json_field_name? string The field name in package.json.
return function(module_name, pkg_json_field_name)
    local patterns = {
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

    return function(...)
        local pkg_json_dir = u.root_pattern("package.json")(...)
        if pkg_json_dir then
            local pkg_json_path = u.path.join(pkg_json_dir, "package.json")
            if vim.fn.filereadable(pkg_json_path) then
                local pkg_json = vim.json.decode(vim.fn.readblob(pkg_json_path))
                local field = pkg_json_field_name or module_name
                if vim.tbl_contains(vim.tbl_keys(pkg_json), field) then
                    return pkg_json_dir
                end
            end
        end

        return u.root_pattern(unpack(patterns))(...)
    end
end
