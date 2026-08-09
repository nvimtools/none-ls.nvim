local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local log = require("null-ls.logger")
local client = require("null-ls.client")

local FORMATTING = methods.internal.FORMATTING

local run_job = function(opts)
    local async = require("plenary.async")
    local Job = require("plenary.job")

    local _run_job = async.wrap(function(_opts, _done)
        _opts.on_exit = function(j, status)
            _done(status, j:result(), j:stderr_result())
        end

        Job:new(_opts):start()
    end, 2)

    return _run_job(opts)
end

local tmpname = function()
    local async = require("plenary.async")

    local mktemp = async.wrap(function(_done)
        vim.defer_fn(function()
            _done(vim.fn.tempname())
        end, 0)
    end, 1)
    return mktemp()
end

--- Asynchronously computes the command that `nix fmt` would run, or nil if
--- we're not in a flake with a formatter, or if we fail to discover the
--- formatter somehow. When finished, it invokes the `done` callback with a
--- single string|nil parameter identifier the `nix fmt` entrypoint if found.
---
--- The formatter must follow treefmt's [formatter
--- spec](https://github.com/numtide/treefmt/blob/main/docs/formatter-spec.md).
---
--- This basically re-implements the "entrypoint discovery" that `nix fmt` does.
--- So why are we doing this ourselves rather than just invoking `nix fmt`?
--- Unfortunately, it can take a few moments to evaluate all your nix code to
--- figure out the formatter entrypoint. It can even be slow enough to exceed
--- Neovim's default LSP timeout.
--- By doing this ourselves, we can cache the result.
local find_nix_fmt = function(opts, done)
    done = vim.schedule_wrap(done)

    -- A malicious project could make `nix fmt` do anything to your computer,
    -- so we ask the user if the project is trusted before we do that.
    local is_project_trusted = vim.secure.read(opts.root)
    if not is_project_trusted then
        log:warn(string.format("nix_flake_fmt disabled because project is not trusted: %s", opts.root))
        done(nil)
        return
    end

    local async = require("plenary.async")

    local notification_title = "discovering `nix fmt` entrypoint"
    local notification_token = "nix-flake-fmt-discovery"

    async.run(function()
        client.send_progress_notification(notification_token, {
            kind = "begin",
            title = notification_title,
        })

        local _done = function(result)
            done(result)
            client.send_progress_notification(notification_token, {
                kind = "end",
                title = notification_title,
                message = "done",
            })
        end

        local nix_fmt_path ---@type string|nil
        local status, stdout_lines, stderr_lines = run_job({
            command = "nix",
            args = {
                "--extra-experimental-features",
                "nix-command",
                "formatter",
                "build",
                "--out-link",
                tmpname(),
            },
            cwd = opts.root,
        })

        if status ~= 0 then
            local stderr = table.concat(stderr_lines, "\n")
            vim.defer_fn(function()
                log:warn(string.format("unable to build 'nix fmt' entrypoint. stderr: %s", stderr))
            end, 0)
            return false
        end

        local stdout = table.concat(stdout_lines, "\n")
        nix_fmt_path = stdout

        return _done(nix_fmt_path)
    end)
end

return h.make_builtin({
    name = "nix flake fmt",
    meta = {
        url = "https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-fmt",
        description = "`nix fmt` - reformat your code in the standard style (this is a generic formatter, not to be confused with nixfmt, a formatter for .nix files)",
    },
    method = FORMATTING,
    filetypes = {},
    generator_opts = {
        -- It can take a few moments to find the `nix fmt` entrypoint. The
        -- underlying command shouldn't change very often for a given
        -- project, so cache it for the project root.
        dynamic_command = h.cache.by_bufroot_async(find_nix_fmt),
        args = {
            "$FILENAME",
        },
        to_temp_file = true,
    },
    condition = function(utils)
        return utils.root_has_file("flake.nix")
    end,
    factory = h.formatter_factory,
})
