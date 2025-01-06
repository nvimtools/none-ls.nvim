return function(opts)
    local h = require("null-ls.helpers")

    -- ignore errors unless otherwise specified
    if opts.ignore_stderr == nil then
        opts.ignore_stderr = true
    end
    -- for formatters, to_temp_file only works if from_temp_file is also set
    if opts.to_temp_file then
        opts.from_temp_file = true
    end

    opts.on_output = function(params, done)
        local output = params.output
        if not output then
            return done()
        end

        return done({ { text = output } })
    end

    if opts.check_exit_code == nil then
        opts.check_exit_code = 0
    end
    opts.check_exit_code = h.check_exit_code(opts.check_exit_code, false, opts.command)

    return h.generator_factory(opts)
end
