local stub = require("luassert.stub")

local code_actions = require("null-ls.builtins").code_actions

local function make_node(node_type, range, opts)
    opts = opts or {}
    local children = opts.children or {}
    local parent = opts.parent
    local node = {}

    function node:type()
        return node_type
    end

    function node:range()
        return range[1], range[2], range[3], range[4]
    end

    function node:parent()
        return parent
    end

    function node:set_parent(p)
        parent = p
    end

    for _, c in ipairs(children) do
        c:set_parent(node)
    end

    return node
end

describe("code_actions impl", function()
    local handler = code_actions.impl.generator.fn
    local get_parser
    local bufnr
    local prev_bufnr

    before_each(function()
        prev_bufnr = vim.api.nvim_get_current_buf()
        bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            "package main",
            "",
            "type Handler struct{}",
        })
        get_parser = stub(vim.treesitter, "get_parser")
    end)

    after_each(function()
        get_parser:revert()
        if vim.api.nvim_buf_is_valid(prev_bufnr) then
            vim.api.nvim_set_current_buf(prev_bufnr)
        end
        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
    end)

    it("should parse syntax tree and return implement interface action at target position", function()
        local type_id = make_node("type_identifier", { 2, 5, 2, 12 })
        local struct_type = make_node("struct_type", { 2, 13, 2, 21 })
        local type_spec = make_node("type_spec", { 2, 5, 2, 21 }, {
            children = { type_id, struct_type },
        })
        make_node("type_declaration", { 2, 0, 2, 21 }, {
            children = { type_spec },
        })

        local parsed = false
        local parser = {
            parse = function()
                parsed = true
                return {}
            end,
            named_node_for_range = function(_, range)
                if not parsed then
                    return nil
                end
                if range[1] == 2 and range[2] == 6 then
                    return type_id
                end
                return nil
            end,
        }
        get_parser.returns(parser)

        local actions = handler({
            bufnr = bufnr,
            range = { row = 3, col = 7 },
        })

        assert.is_true(parsed)
        assert.is_table(actions)
        assert.equals(1, #actions)
        assert.equals("impl: implement interface", actions[1].title)
    end)

    it("should use params.range instead of window cursor on current buffer", function()
        vim.api.nvim_set_current_buf(bufnr)
        vim.api.nvim_win_set_cursor(0, { 1, 0 })

        local type_id = make_node("type_identifier", { 2, 5, 2, 12 })
        local struct_type = make_node("struct_type", { 2, 13, 2, 21 })
        local type_spec = make_node("type_spec", { 2, 5, 2, 21 }, {
            children = { type_id, struct_type },
        })
        make_node("type_declaration", { 2, 0, 2, 21 }, {
            children = { type_spec },
        })

        local parsed = false
        local parser = {
            parse = function()
                parsed = true
                return {}
            end,
            named_node_for_range = function(_, range)
                if not parsed then
                    return nil
                end
                if range[1] == 2 and range[2] == 6 then
                    return type_id
                end
                return nil
            end,
        }
        get_parser.returns(parser)

        local actions = handler({
            bufnr = bufnr,
            range = { row = 3, col = 7 },
        })

        assert.is_true(parsed)
        assert.is_table(actions)
        assert.equals(1, #actions)
        assert.equals("impl: implement interface", actions[1].title)
    end)

    it("should return nil when go parser is unavailable", function()
        get_parser.returns(nil)

        local actions = handler({
            bufnr = bufnr,
            range = { row = 3, col = 7 },
        })

        assert.is_nil(actions)
    end)
end)
