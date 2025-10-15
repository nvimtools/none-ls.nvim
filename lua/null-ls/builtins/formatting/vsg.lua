local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "VSG Formatting",
    meta = {
        url = "https://github.com/jeremiah-c-leary/vhdl-style-guide",
        description = "VHDL Style guide is a tool for linting for fixing styple in VHDL files",
        config = {
            {
                key = "config_file_name",
                type = "string",
                description = "Name of the VSG config file to use. If this file is present in the root, it will be passed to vsg with the `-c` option",
                usage = "vsg_config.yaml",
            },
        },
    },
    method = FORMATTING,
    filetypes = { "vhdl" },
    generator_opts = {
        command = "vsg",
        args = function(params)
            local rv = {}
            local config_file_name = params:get_config().config_file_name
            -- check if there is a config file in the root directory, if so
            -- insert the -c argument with it
            if config_file_name and vim.fn.filereadable(params.root .. "/" .. config_file_name) == 1 then
                table.insert(rv, "-c=" .. params.root .. "/" .. config_file_name)
            end
            table.insert(rv, "-of=syntastic")
            table.insert(rv, "-f=$FILENAME")
            table.insert(rv, "--fix")
            return rv
        end,
        cwd = nil,
        check_exit_code = { 0, 1 },
        ignore_stderr = true,
        to_temp_file = true,
        from_temp_file = true,
        to_stdin = false,
        multiple_files = false,
    },
    factory = h.formatter_factory,
})
