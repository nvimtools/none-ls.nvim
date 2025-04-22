local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local log = require("null-ls.logger")
local client = require("null-ls.client")

local FORMATTING = methods.internal.FORMATTING
local NOTIFICATION_TITLE = "discovering `nix fmt` entrypoint"
local NOTIFICATION_TOKEN = "nix-flake-fmt-discovery"

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

    local async = require("plenary.async")
    local Job = require("plenary.job")

    local run_job = async.wrap(function(_opts, _done)
        _opts.on_exit = function(j, status)
            _done(status, j:result(), j:stderr_result())
        end

        Job:new(_opts):start()
    end, 2)

    local tmpname = async.wrap(function(_done)
        vim.defer_fn(function()
            _done(vim.fn.tempname())
        end, 0)
    end, 1)

    local get_current_system = function()
        local status, stdout_lines, stderr_lines = run_job({
            command = "nix",
            args = {
                "--extra-experimental-features",
                "nix-command",
                "config",
                "show",
                "system",
            },
        })

        if status ~= 0 then
            local stderr = table.concat(stderr_lines, "\n")
            vim.defer_fn(function()
                log:warn(string.format("unable to discover builtins.currentSystem from nix. stderr: %s", stderr))
            end, 0)
            return
        end

        local nix_current_system = stdout_lines[1]
        return nix_current_system
    end

    local evaluate_flake_formatter = function(root)
        local nix_current_system = get_current_system()
        if nix_current_system == nil then
            return
        end

        local eval_nix_formatter = [[
          let
            system = "]] .. nix_current_system .. [[";
            # Various functions vendored from nixpkgs lib (to avoid adding a
            # dependency on nixpkgs).
            lib = rec {
              getOutput = output: pkg:
                if ! pkg ? outputSpecified || ! pkg.outputSpecified
                then pkg.${output} or pkg.out or pkg
                else pkg;
              getBin = getOutput "bin";
              # Simplified by removing various type assertions.
              getExe' = x: y: "${getBin x}/bin/${y}";
              # getExe is simplified to assume meta.mainProgram is specified.
              getExe = x: getExe' x x.meta.mainProgram;
            };
          in
          formatterBySystem:
            builtins.toJSON (
              if formatterBySystem ? ${system} then
                let
                  formatter = formatterBySystem.${system};
                  drv = formatter.drvPath;
                  bin = lib.getExe formatter;
                in
                { inherit drv bin; }
              else
                { error = "this flake does not define a formatter for system: ${system}"; }
            )
        ]]

        client.send_progress_notification(NOTIFICATION_TOKEN, {
            kind = "report",
            title = NOTIFICATION_TITLE,
            message = "evaluating",
        })

        local status, stdout_lines, stderr_lines = run_job({
            command = "nix",
            args = {
                "--extra-experimental-features",
                "nix-command flakes",
                "eval",
                ".#formatter",
                "--raw",
                "--apply",
                eval_nix_formatter,
            },
            cwd = root,
        })

        if status ~= 0 then
            local stderr = table.concat(stderr_lines, "\n")
            vim.defer_fn(function()
                log:warn(string.format("unable to discover 'nix fmt' command. stderr: %s", stderr))
            end, 0)
            return
        end

        local stdout = table.concat(stdout_lines, "\n")
        local result = vim.json.decode(stdout)

        if result.error ~= nil then
            vim.defer_fn(function()
                log:warn(result.error)
            end, 0)
            return
        end

        local drv_path = result.drv
        local nix_fmt_path = result.bin
        return drv_path, nix_fmt_path
    end

    local build_derivation = function(options)
        if type(options.drv) ~= "string" then
            error("missing drv")
        elseif type(options.out_link) ~= "string" then
            error("missing out_link")
        end

        local drv_path = options.drv
        local out_link = options.out_link

        local status, _, stderr_lines = run_job({
            command = "nix",
            args = {
                "--extra-experimental-features",
                "nix-command",
                "build",
                "--out-link",
                out_link,
                drv_path .. "^out",
            },
        })

        if status ~= 0 then
            local stderr = table.concat(stderr_lines, "\n")
            vim.defer_fn(function()
                log:warn(string.format("unable to build 'nix fmt' entrypoint. stderr: %s", stderr))
            end, 0)
            return false
        end

        return true
    end

    async.run(function()
        client.send_progress_notification(NOTIFICATION_TOKEN, {
            kind = "begin",
            title = NOTIFICATION_TITLE,
        })

        local drv_path, nix_fmt_path = evaluate_flake_formatter(opts.root)
        if drv_path == nil then
            return
        end

        -- Build the derivation. This ensures that `nix_fmt_path` exists.
        client.send_progress_notification(NOTIFICATION_TOKEN, {
            kind = "report",
            title = NOTIFICATION_TITLE,
            message = "building",
        })
        if not build_derivation({ drv = drv_path, out_link = tmpname() }) then
            done(nil)
            return
        end

        client.send_progress_notification(NOTIFICATION_TOKEN, {
            kind = "end",
            title = NOTIFICATION_TITLE,
            message = "done",
        })

        done(nix_fmt_path)
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
