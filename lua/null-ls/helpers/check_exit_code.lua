return function(success_codes)
    return function(code, stderr)
        local success

        if type(success_codes) == "number" then
            success = code <= success_codes
        else
            success = vim.tbl_contains(success_codes, code)
        end

        if not success then
            vim.schedule(function()
                require("null-ls.logger"):warn(("failed to format: %s"):format(stderr))
            end)
        end
    end
end
