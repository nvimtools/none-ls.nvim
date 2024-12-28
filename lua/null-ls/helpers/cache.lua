local next_key = 0

local M = {}

M._reset = function()
    M.cache = {}
end

M._reset()

---@class NullLsCacheParams
---@field bufnr number
---@field root string

--- creates a function that caches the output of a callback, indexed by bufnr
---@param cb function
---@return fun(params: NullLsCacheParams): any
M.by_bufnr = function(cb)
    -- assign next available key, since we just want to avoid collisions
    local key = next_key
    next_key = next_key + 1

    return function(params)
        local bufnr = params.bufnr

        if M.cache[key] == nil then
            M.cache[key] = {}
        end

        -- if we haven't cached a value yet, get it from cb
        if M.cache[key][bufnr] == nil then
            -- make sure we always store a value so we know we've already called cb
            M.cache[key][bufnr] = cb(params) or false
        end

        return M.cache[key][bufnr]
    end
end

--- creates a function that caches the output of an async callback, indexed by bufnr
---@param cb function
---@return fun(params: NullLsCacheParams): any
M.by_bufnr_async = function(cb)
    -- assign next available key, since we just want to avoid collisions
    local key = next_key
    M.cache[key] = {}
    next_key = next_key + 1

    return function(params, done)
        local bufnr = params.bufnr
        -- if we haven't cached a value yet, get it from cb
        if M.cache[key][bufnr] == nil then
            -- make sure we always store a value so we know we've already called cb
            cb(params, function(result)
                M.cache[key][bufnr] = result or false
                done(M.cache[key][bufnr])
            end)
        else
            done(M.cache[key][bufnr])
        end
    end
end

--- creates a function that caches the output of an async callback, indexed by project root
---@param cb function
---@return fun(params: NullLsParams): any
M.by_bufroot_async = function(cb)
    -- assign next available key, since we just want to avoid collisions
    local key = next_key
    M.cache[key] = {}
    next_key = next_key + 1

    return function(params, done)
        local root = params.root
        -- if we haven't cached a value yet, get it from cb
        if M.cache[key][root] == nil then
            -- make sure we always store a value so we know we've already called cb
            cb(params, function(result)
                M.cache[key][root] = result or false
                done(M.cache[key][root])
            end)
        else
            done(M.cache[key][root])
        end
    end
end

return M
