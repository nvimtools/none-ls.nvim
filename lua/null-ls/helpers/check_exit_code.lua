local logger = require("null-ls.logger")

return function(success_codes, command)
    return function(code, stderr)
        local success

        if type(success_codes) == "number" then
            success = code <= success_codes
        else
            success = vim.tbl_contains(success_codes, code)
        end

        if not success then
            vim.schedule(function()
                logger:warn(string.format("failed to run formatter %s; see `:NullLsLog`", command))
                logger:add_entry(string.format("failed to run formatter %s: %s", command, stderr), "warn")
            end)
        end
    end
end
