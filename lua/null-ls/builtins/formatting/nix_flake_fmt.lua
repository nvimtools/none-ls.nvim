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

--- Asynchronously build and return the formatter for the flake located at {root},
--- If {root} is not a flake, or does not have a formatter, or we cannot build the formatter, return `nil`.
--- This legacy codepath is quite complicated, and unnecessary now that `nix` has core support for
--- returning the fromatter command.
--- TODO: remove after the `nix formatter` subcommand has been released for a while.
--- The command was introduced in https://github.com/NixOS/nix/commit/d155bb901241441149c701b9efc92f5785c2e1c3
---
--- @param root string
--- @return string|nil
local legacy_find_nix_fmt = function(root)
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

    local get_flake_ref = function(_root)
        local status, stdout_lines, stderr_lines = run_job({
            command = "nix",
            args = {
                "--extra-experimental-features",
                "nix-command flakes",
                "flake",
                "metadata",
                "--json",
                _root,
            },
        })

        if status ~= 0 then
            local stderr = table.concat(stderr_lines, "\n")
            vim.defer_fn(function()
                log:warn(string.format("unable to get flake ref for '%s'. stderr: %s", root, stderr))
            end, 0)
            return
        end

        local stdout = table.concat(stdout_lines, "\n")
        local metadata = vim.json.decode(stdout)
        local flake_ref = metadata.resolvedUrl
        if flake_ref == nil then
            vim.defer_fn(function()
                log:warn(
                    string.format("flake metadata does not have a 'resolvedUrl'. metadata: %s", vim.inspect(metadata))
                )
            end, 0)
            return
        end

        return flake_ref
    end

    local evaluate_flake_formatter = function(_root)
        local nix_current_system = get_current_system()
        if nix_current_system == nil then
            return
        end
        local flake_ref = get_flake_ref(_root)
        if flake_ref == nil then
            return
        end
        local eval_nix_formatter = [[
          let
            system = "]] .. nix_current_system .. [[";
            flake = builtins.getFlake "]] .. flake_ref .. [[";
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
            result =
              if flake ? formatter then
                if flake.formatter ? ${system} then
                  let
                    formatter = flake.formatter.${system};
                    drv = formatter.drvPath;
                    bin = lib.getExe formatter;
                  in
                  { inherit drv bin; }
                else
                  { error = "this flake does not define a formatter for system: ${system}"; }
              else
                { error = "this flake does not define any formatters"; };
          in
            builtins.toJSON result
        ]]

        local status, stdout_lines, stderr_lines = run_job({
            command = "nix",
            args = {
                "--extra-experimental-features",
                "nix-command flakes",
                "eval",
                "--raw",
                -- We need `--impure` to be able to call `builtins.getFlake`
                -- on an unlocked flake ref.
                "--impure",
                "--expr",
                eval_nix_formatter,
            },
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

    local drv_path, nix_fmt_path = evaluate_flake_formatter(root)
    if drv_path == nil then
        return nil
    end

    -- Build the derivation. This ensures that `nix_fmt_path` exists.
    if not build_derivation({ drv = drv_path, out_link = tmpname() }) then
        return nil
    end

    return nix_fmt_path
end

local nix_has_formatter_subcommand = function()
    local status, _, _ = run_job({
        command = "nix",
        args = {
            "--extra-experimental-features",
            "nix-command flakes",
            "formatter",
            "--help",
        },
    })

    return status == 0
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
        local is_legacy = not nix_has_formatter_subcommand()
        if is_legacy then
            nix_fmt_path = legacy_find_nix_fmt(opts.root)
        else
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
        end

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
    condition = function(_)
        return vim.fs.root(".", "flake.nix") ~= nil
    end,
    factory = h.formatter_factory,
})
