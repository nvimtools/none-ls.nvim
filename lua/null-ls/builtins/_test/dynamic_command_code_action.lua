local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local CODE_ACTION = methods.internal.CODE_ACTION

return h.make_builtin({
    method = CODE_ACTION,
    filetypes = { "text" },
    generator_opts = {
        on_output = function(_params, done)
            return done({
                {
                    title = "an action",
                    action = function() end,
                },
            })
        end,
    },
    factory = function(opts)
        opts._dynamic_command_call_count = 0
        opts.dynamic_command = function(_params, done)
            opts._dynamic_command_call_count = opts._dynamic_command_call_count + 1
            done("ls")
        end
        return h.generator_factory(opts)
    end,
})
