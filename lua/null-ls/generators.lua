local client = require("null-ls.client")
local log = require("null-ls.logger")
local methods = require("null-ls.methods")

local M = {}

local progress_token = 0

-- returns a function that when first called calls the wrapped function
-- and returns its returned values.
-- On consecutive calls the function is not called and the function retursn nil.
-- Don't confuse this with a memoized function, here we are explicitly ignoring
-- the returned results to avoid holding them in memory because we know we won't
-- need them.
local once = function(func)
    local called = nil
    return function(...)
        if called == nil then
            called = true
            return func(...)
        end
    end
end

-- Think about this function as plenary's wrap, but for iterators.
local wrap_iter = function(func, argc)
    local once_func = once(func)
    return function(...)
        local params = { ... }
        return function()
            return coroutine.yield(once_func, argc, unpack(params))
        end
    end
end

M.run = function(generators, params, opts, callback)
    local a = require("plenary.async")

    local all_results = {}
    local safe_callback = function()
        if not callback then
            return
        end

        callback(all_results)
    end

    log:trace("running generators for method " .. params.method)

    if vim.tbl_isempty(generators) then
        log:debug("no generators available")
        safe_callback()
        return
    end

    local current_progress_token = nil
    if params.method ~= methods.internal.COMPLETION then
        -- progress messages for completion lead to too
        -- much noise in the tests.
        progress_token = progress_token + 1
        current_progress_token = progress_token
    end

    local futures = {}
    local copy_params = function(to_copy)
        if #generators < 2 then
            return to_copy
        end

        return vim.deepcopy(to_copy)
    end

    for i, generator in ipairs(generators) do
        table.insert(futures, function()
            local copied_params = copy_params(opts.make_params and opts.make_params() or params)
            -- pass to enable params:get_source()
            copied_params.source_id = generator.source_id

            local runtime_condition = generator.opts and generator.opts.runtime_condition
            if runtime_condition and not runtime_condition(copied_params) then
                return
            end

            if current_progress_token then
                client.send_progress_notification(current_progress_token, {
                    kind = "report",
                    message = generator.opts and generator.opts.name,
                    percentage = math.floor((i - 1) / #generators * 100),
                })
            end

            -- filter results with the filter option
            local filter = generator.opts and generator.opts.filter
            local postprocess, after_each = opts.postprocess, opts.after_each

            if generator.async_iterator then
                local results = {}
                local iter = wrap_iter(generator.fn, 2)
                local no_results = true
                for result in iter(copied_params) do
                    if not filter or filter(result) then
                        no_results = false
                        if postprocess then
                            postprocess(result, copied_params, generator)
                        end

                        table.insert(results, result)
                        table.insert(all_results, result)

                        if after_each then
                            after_each(results, copied_params, generator)
                        end
                    end
                end
                if no_results and after_each then
                    a.util.scheduler()
                    after_each(results, copied_params, generator)
                end
            else
                local to_run = generator.async and a.wrap(generator.fn, 2) or generator.fn
                local protected_call = generator.async and a.util.apcall or pcall
                local ok, results = protected_call(to_run, copied_params)
                a.util.scheduler()

                -- filter results with the filter option
                if filter and results then
                    results = vim.tbl_filter(filter, results)
                end

                if results then
                    -- allow generators to pass errors without throwing them (e.g. in luv callbacks)
                    if results._generator_err then
                        ok = false
                        results = results._generator_err
                    end

                    -- allow generators to deregister their parent sources
                    if results._should_deregister and generator.source_id then
                        results = nil
                        vim.schedule(function()
                            require("null-ls.sources").deregister({ id = generator.source_id })
                        end)
                    end
                end

                -- TODO: pass generator error trace
                if not ok then
                    log:warn("failed to run generator: " .. results)
                    generator._failed = true
                    return
                end

                results = results or {}
                for _, result in ipairs(results) do
                    if postprocess then
                        postprocess(result, copied_params, generator)
                    end

                    table.insert(all_results, result)
                end

                if after_each then
                    after_each(results, copied_params, generator)
                end
            end
        end)
    end

    a.run(function()
        if current_progress_token then
            client.send_progress_notification(current_progress_token, {
                kind = "begin",
                title = require("null-ls.methods").internal[params.method]:lower(),
                percentage = 0,
            })
        end

        if opts.sequential then
            for _, future in ipairs(futures) do
                future()
            end
        else
            a.util.join(futures)
        end
    end, function()
        if current_progress_token then
            client.send_progress_notification(current_progress_token, {
                kind = "end",
                percentage = 100,
            })
        end
        safe_callback()
    end)
end

M.run_sequentially = function(generators, make_params, opts, callback)
    M.run(generators, make_params(), {
        sequential = true,
        postprocess = opts.postprocess,
        after_each = opts.after_each,
        make_params = make_params,
    }, callback)
end

M.run_registered = function(opts)
    local filetype, method, params, postprocess, callback, after_each =
        opts.filetype, opts.method, opts.params, opts.postprocess, opts.callback, opts.after_each
    local generators = M.get_available(filetype, method)

    M.run(generators, params, { postprocess = postprocess, after_each = after_each }, callback)
end

M.run_registered_sequentially = function(opts)
    local filetype, method, make_params, postprocess, callback, after_each, after_all =
        opts.filetype, opts.method, opts.make_params, opts.postprocess, opts.callback, opts.after_each, opts.after_all
    local generators = M.get_available(filetype, method)

    M.run_sequentially(
        generators,
        make_params,
        { postprocess = postprocess, after_each = after_each, after_all = after_all },
        callback
    )
end

M.get_available = function(filetype, method)
    local available = {}
    for _, source in ipairs(require("null-ls.sources").get_available(filetype, method)) do
        table.insert(available, source.generator)
    end
    return available
end

M.can_run = function(filetype, method)
    return #M.get_available(filetype, method) > 0
end

return M
