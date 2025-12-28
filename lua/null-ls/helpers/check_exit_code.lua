return function(codes, silent, command)
    local logger = require("null-ls.logger")

    local check = codes
    if type(codes) == "table" then
        check = function(code, _)
            return vim.tbl_contains(codes, code)
        end
    elseif type(codes) == "number" then
        check = function(code, _)
            return code <= codes
        end
    end

    if not silent and type(check) == "function" then
        local _check = check
        check = function(code, stderr)
            local result = _check(code)

            if not result then
                logger:warn(string.format("failed to run %s; see `:NullLsLog`", command))
                logger:add_entry(string.format("failed to run %s: %s", command, stderr), "warn")
            end

            return result
        end
    end
    return check
end
