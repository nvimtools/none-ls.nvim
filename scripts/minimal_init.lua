vim.g.loaded_remote_plugins = ""
vim.o.runtimepath = vim.env["VIMRUNTIME"]

local temp_dir = vim.fs.dirname(vim.fn.tempname())

vim.o.packpath = vim.fs.joinpath(temp_dir, "nvim", "site")

local package_root = vim.fs.joinpath(temp_dir, "nvim", "site", "pack")
local install_path = vim.fs.joinpath(package_root, "deps", "start", "mini.deps")

local null_ls_config = function()
    local null_ls = require("null-ls")
    -- add only what you need to reproduce your issue
    null_ls.setup({
        sources = {},
        debug = true,
    })
end

local function load_plugins()
    -- only add other plugins if they are necessary to reproduce the issue
    local deps = require("mini.deps")
    deps.setup({
        path = {
            package = package_root,
        },
    })
    deps.add({
        source = "nvimtools/none-ls.nvim",
        depends = { "nvim-lua/plenary.nvim" },
    })
    deps.later(null_ls_config)
end

if vim.fn.isdirectory(install_path) == 0 then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.deps", install_path })
end
load_plugins()
