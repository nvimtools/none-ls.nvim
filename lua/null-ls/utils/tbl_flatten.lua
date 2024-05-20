local M = {}

function M.tbl_flatten(t)
    return vim.fn.has("nvim-0.10") == 1 and vim.iter(t):flatten(math.huge):totable() or vim.tbl_flatten(t)
end

return M
