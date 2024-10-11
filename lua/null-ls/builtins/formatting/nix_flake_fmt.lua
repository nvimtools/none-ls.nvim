local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local log = require("null-ls.logger")
local client = require("null-ls.client")
local async = require("plenary.async")
local Job = require("plenary.job")

local FORMATTING = methods.internal.FORMATTING

local run_job = async.wrap(function(opts, done)
    opts.on_exit = function(j, status)
        done(status, j:result(), j:stderr_result())
    end

    Job:new(opts):start()
end, 2)

--- Return the command that `nix fmt` would run, or nil if we're not in a
--- flake.
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
---
---@return string|nil
local find_nix_fmt = function(opts, done)
    async.run(function()
        local title = "discovering `nix fmt` entrypoint"
        local progress_token = "nix-flake-fmt-discovery"

        client.send_progress_notification(progress_token, {
            kind = "begin",
            title = title,
        })

        local root = opts.root

        -- Discovering currentSystem here lets us keep the *next* eval pure.
        -- We want to keep that part pure as a performance improvement: an impure
        -- eval that references the flake would copy *all* files (including
        -- gitignored files!), which can be quite expensive if you've got many GiB
        -- of artifacts in the directory. This optimization can probably go away
        -- once the [Lazy trees PR] lands.
        --
        -- [Lazy trees PR]: https://github.com/NixOS/nix/pull/6530
        local status, stdout_lines, stderr_lines = run_job({
            command = "nix",
            args = { "eval", "--impure", "--expr", "builtins.currentSystem" },
        })

        if status ~= 0 then
            local stderr = table.concat(stderr_lines, "\n")
            log:warn(string.format("unable to discover builtins.currentSystem from nix. stderr: %s", stderr))
            return nil
        end

        local nix_current_system_expr = stdout_lines[1]

        local eval_nix_formatter = [[
          let
            currentSystem = ]] .. nix_current_system_expr .. [[;
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
            if formatterBySystem ? ${currentSystem} then
              let
                formatter = formatterBySystem.${currentSystem};
                drv = formatter.drvPath;
                bin = lib.getExe formatter;
              in
                drv + "\n" + bin + "\n"
            else
              ""
        ]]

        client.send_progress_notification(progress_token, {
            kind = "report",
            title = title,
            message = "evaluating",
        })
        status, stdout_lines, stderr_lines = run_job({
            command = "nix",
            args = { "eval", ".#formatter", "--raw", "--apply", eval_nix_formatter },
            cwd = root,
        })

        if status ~= 0 then
            local stderr = table.concat(stderr_lines, "\n")
            -- Dirty hack to check if the flake actually defines a formatter.
            --
            -- I cannot for the *life* of me figure out a less hacky way of
            -- checking if a flake defines a formatter. Things I've tried:
            --
            --   - `nix eval . --apply '...'`: This doesn't not give me the flake
            --                                 itself, it gives me the default package.
            --   - `builtins.getFlake`: Every incantation I've tried requires
            --                          `--impure`, which has the performance downside described above.
            --   - `nix flake show --json .`: This works, but it can be quite slow:
            --                                we end up evaluating all outputs, which can take a while for
            --                                `nixosConfigurations`.
            if stderr:find("error: flake .+ does not provide attribute .+ or 'formatter'") then
                log:warn("this flake does not define a `nix fmt` entrypoint")
            else
                log:error(string.format("unable discover 'nix fmt' command. stderr: %s", stderr))
            end

            return nil
        end

        if #stdout_lines == 0 then
            log:warn("this flake does not define a formatter for your system: %s", nix_current_system_expr)
            return nil
        end

        -- stdout has 2 lines of output:
        --  1. drv path
        --  2. exe path
        local drv_path, nix_fmt_path = unpack(stdout_lines)

        -- Build the derivation. This ensures that `nix_fmt_path` exists.
        client.send_progress_notification(progress_token, {
            kind = "report",
            title = title,
            message = "building",
        })
        status, stdout_lines, stderr_lines = run_job({
            command = "nix",
            args = { "build", "--no-link", drv_path .. "^out" },
        })

        if status ~= 0 then
            log:warn(string.format("unable to build 'nix fmt' entrypoint. stderr: %s", job:stderr_results()))
            return nil
        end

        client.send_progress_notification(progress_token, {
            kind = "end",
            title = title,
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
        dynamic_command = h.cache.by_bufroot(find_nix_fmt),
        args = {
            -- `--walk` is specific to treefmt, and this formatter is supposed
            -- to be generic.
            -- Note: this could get converted to the new `TREEFMT_WALK`
            -- environment variable once
            -- <https://github.com/numtide/treefmt/commit/bac4a0d102e1142406d3a7d15106e5ba108bfcf8>
            -- is fixed, which would at least play nicely with other types of
            -- `nix fmt` entrypoints.
            --
            -- However, IMO, the real fix is to change treefmt itself to be
            -- willing to format files passed explicitly, even if they're
            -- gitignored:
            -- https://github.com/numtide/treefmt/issues/435
            "--walk=filesystem",
            "$FILENAME",
        },
        to_temp_file = true,
    },
    condition = function(utils)
        return utils.root_has_file("flake.nix")
    end,
    factory = h.formatter_factory,
})
