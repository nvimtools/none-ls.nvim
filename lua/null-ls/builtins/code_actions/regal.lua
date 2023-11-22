local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local logger = require("null-ls.logger")
local Job = require("plenary.job")

local CODE_ACTION = methods.internal.CODE_ACTION
local REGAL_CFG = ".regal/config.yaml"

local line_diagnostics = function(params)
    local col = params.col

    local diagnostics = {}
    for _, d in ipairs(vim.diagnostic.get(params.bufnr, { lnum = params.row - 1 })) do
        if d.source == "regal" and col >= d.col and col < d.end_col then
            table.insert(diagnostics, d)
        end
    end
    return diagnostics
end

local ignore_inline_action = function(params, d, prev_ln, prev_ign, indent)
    return {
        title = "Ignore Regal rule '" .. d.code .. "' for this line",
        action = function()
            local ign = prev_ign == nil and indent .. "# regal ignore:" or prev_ln .. ","
            local lnum = prev_ign == nil and d.lnum or d.lnum - 1

            vim.api.nvim_buf_set_lines(params.bufnr, lnum, d.lnum, false, { ign .. d.code })
            vim.api.nvim_command("write")
        end,
    }
end

local ignore_config_action = function(d)
    return {
        title = "Ignore Regal rule '" .. d.code .. "' via " .. REGAL_CFG,
        action = function()
            Job:new({
                command = "yq",
                args = {
                    "-i",
                    ".rules." .. d.user_data.category .. "." .. d.code .. '.level|="ignore"',
                    REGAL_CFG,
                },
                on_exit = vim.schedule_wrap(function(j, return_val)
                    if return_val ~= 0 then
                        logger:error(j:stderr_result()[1])
                    else
                        vim.notify(
                            "'" .. d.code .. "' ignored in " .. REGAL_CFG,
                            vim.log.levels.INFO,
                            { title = "none-ls" }
                        )
                        vim.api.nvim_command("write")
                    end
                end),
            }):start()
        end,
    }
end

local code_actions_handler = function(params)
    local actions = {}

    local diagnostics = line_diagnostics(params)
    if vim.tbl_isempty(diagnostics) then
        return actions
    end

    local indent = params.content[params.row]:match("^%s+") or ""
    local prev_ln = params.row > 1 and params.content[params.row - 1] or ""
    local _, _, prev_ign = prev_ln:find("#%s+regal%s+ignore:([%a%-,]+)")

    for _, d in ipairs(diagnostics) do
        table.insert(actions, ignore_inline_action(params, d, prev_ln, prev_ign, indent))
        table.insert(actions, ignore_config_action(d))
    end

    return actions
end

return h.make_builtin({
    name = "regal",
    meta = {
        url = "https://docs.styra.com/regal",
        description = "Allows ignoring broken rules from Regal linter.",
    },
    method = CODE_ACTION,
    filetypes = { "rego" },
    generator_opts = { handler = code_actions_handler },
    generator = { fn = code_actions_handler },
})
