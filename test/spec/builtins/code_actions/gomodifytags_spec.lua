local stub = require("luassert.stub")

local code_actions = require("null-ls.builtins").code_actions

local function make_node(node_type, range, opts)
    opts = opts or {}
    local children = opts.children or {}
    local fields = opts.fields or {}
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

    function node:child_count()
        return #children
    end

    function node:child(idx)
        return children[idx + 1]
    end

    function node:field(name)
        return fields[name] or {}
    end

    for _, c in ipairs(children) do
        c:set_parent(node)
    end

    return node
end

describe("code_actions gomodifytags", function()
    local handler = code_actions.gomodifytags.generator.fn
    local get_parser
    local bufnr
    local prev_bufnr

    before_each(function()
        prev_bufnr = vim.api.nvim_get_current_buf()
        bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            "package main",
            "",
            "type User struct {",
            "\tName string",
            "}",
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

    local function build_struct_tree()
        -- Line 2 (0-indexed): "type User struct {"
        -- Line 3 (0-indexed): "\tName string"
        local type_id = make_node("type_identifier", { 2, 5, 2, 9 })
        local field_id = make_node("field_identifier", { 3, 1, 3, 5 })
        local field_type = make_node("type_identifier", { 3, 6, 3, 12 })
        local field_decl = make_node("field_declaration", { 3, 1, 3, 12 }, {
            children = { field_id, field_type },
        })
        local field_list = make_node("field_declaration_list", { 2, 17, 4, 1 }, {
            children = { field_decl },
        })
        local struct_type = make_node("struct_type", { 2, 10, 4, 1 }, {
            children = { field_list },
        })
        local type_spec = make_node("type_spec", { 2, 5, 4, 1 }, {
            children = { type_id, struct_type },
            fields = { type = { struct_type } },
        })
        make_node("type_declaration", { 2, 0, 4, 1 }, {
            children = { make_node("type", { 2, 0, 2, 4 }), type_spec },
        })

        return {
            type_id = type_id,
            field_id = field_id,
        }
    end

    it("should parse syntax tree and return struct actions at target position", function()
        local nodes = build_struct_tree()
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
                    return nodes.type_id
                end
                return nil
            end,
        }
        get_parser.returns(parser)

        local actions = handler({
            bufnr = bufnr,
            bufname = "user.go",
            range = { row = 3, col = 7 },
        })

        assert.is_true(parsed)
        assert.is_table(actions)
        assert.equals(7, #actions)
        assert.equals("gomodifytags: add tags", actions[1].title)
    end)

    it("should parse syntax tree and execute field action with struct and field names", function()
        local nodes = build_struct_tree()
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
                if range[1] == 3 and range[2] == 2 then
                    return nodes.field_id
                end
                return nil
            end,
        }
        get_parser.returns(parser)

        local fn_execute = stub(vim.fn, "execute")
        local fn_system = stub(vim.fn, "system")
        local get_vvar = stub(vim.api, "nvim_get_vvar")
        get_vvar.returns(0)

        local actions = handler({
            bufnr = bufnr,
            bufname = "user.go",
            range = { row = 4, col = 3 },
        })

        assert.is_true(parsed)
        assert.is_table(actions)
        assert.equals(7, #actions)
        assert.equals("gomodifytags: clear tags", actions[4].title)

        actions[4].action()
        assert
            .stub(fn_system)
            .was_called_with("gomodifytags -quiet -w -file user.go -struct User -field Name -clear-tags")

        fn_execute:revert()
        fn_system:revert()
        get_vvar:revert()
    end)

    it("should use params.range instead of window cursor on current buffer", function()
        vim.api.nvim_set_current_buf(bufnr)
        vim.api.nvim_win_set_cursor(0, { 1, 0 })

        local nodes = build_struct_tree()
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
                    return nodes.type_id
                end
                return nil
            end,
        }
        get_parser.returns(parser)

        local actions = handler({
            bufnr = bufnr,
            bufname = "user.go",
            range = { row = 3, col = 7 },
        })

        assert.is_true(parsed)
        assert.is_table(actions)
        assert.equals(7, #actions)
    end)

    it("should return nil when go parser is unavailable", function()
        get_parser.returns(nil)

        local actions = handler({
            bufnr = bufnr,
            bufname = "user.go",
            range = { row = 3, col = 7 },
        })

        assert.is_nil(actions)
    end)
end)
