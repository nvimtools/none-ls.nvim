local logger = require("null-ls.logger")

return function(success_codes)
    return function(code, stderr)
        local success

        if type(success_codes) == "number" then
            success = code <= success_codes
        else
            success = vim.tbl_contains(success_codes, code)
        end

        if not success then
            logger:add_entry(("failed to run formatter: %s"):format(stderr), "warn")
            vim.schedule(function()
                logger:warn("failed to run formatter; see `:NullLsLog`")
            end)
        end
    end
end
