local stub = require("luassert.stub")

local diagnostics = require("null-ls.builtins").diagnostics

stub(vim, "notify")

describe("diagnostics regal", function()
    local parser = diagnostics.regal._opts.on_output

    it("should create a diagnostic with error severity", function()
        local output = vim.json.decode([[
          {
            "violations": [
              {
                "title": "prefer-snake-case",
                "description": "Prefer snake_case for names",
                "category": "style",
                "level": "error",
                "location": {
                  "col": 9,
                  "row": 3,
                  "file": "test.rego",
                  "text": "default allowRbac := true"
                }
              }
            ]
          }
        ]])
        local diagnostic = parser({ output = output })
        assert.same({
            {
                row = 3,
                col = 9,
                end_col = 26,
                severity = vim.diagnostic.severity.ERROR,
                message = "Prefer snake_case for names",
                filename = "test.rego",
                source = "regal",
                code = "prefer-snake-case",
                user_data = { category = "style" },
            },
        }, diagnostic)
    end)

    it("should not create a diagnostic without location", function()
        local output = vim.json.decode([[
          {
            "violations": [
              {
                "title": "prefer-snake-case",
                "description": "Prefer snake_case for names",
                "category": "style",
                "level": "error"
              }
            ]
          }
        ]])
        local diagnostic = parser({ output = output })
        assert.same({}, diagnostic)
    end)

    it("should log error for non-json output", function()
        local diagnostic = parser({ output = "non-json-output", err = "json error" })
        assert.same({}, diagnostic)
        assert
            .stub(vim.notify)
            .was_called_with("[null-ls] non-json-output", vim.log.levels.ERROR, { title = "null-ls" })
    end)

    it("should deduce severiry or fallback to error", function()
        local output = vim.json.decode([[
          {
            "violations": [
              {
                "title": "prefer-snake-case",
                "description": "Prefer snake_case for names",
                "category": "style",
                "location": {
                  "col": 9,
                  "row": 3,
                  "file": "test.rego",
                  "text": "default allowRbac := true"
                }
              }
            ]
          }
        ]])

        output.violations[1].level = "error"
        local diagnostic = parser({ output = output })
        assert.same(vim.diagnostic.severity.ERROR, diagnostic[1].severity)

        output.violations[1].level = "warning"
        diagnostic = parser({ output = output })
        assert.same(vim.diagnostic.severity.WARN, diagnostic[1].severity)

        output.violations[1].level = "qwe"
        diagnostic = parser({ output = output })
        assert.same(vim.diagnostic.severity.ERROR, diagnostic[1].severity)
    end)
end)
