local diagnostics = require("null-ls.builtins").diagnostics

describe("diagnostics opacheck", function()
    local parser = diagnostics.opacheck._opts.on_output

    it("should create a diagnostic with error severity", function()
        local output = vim.json.decode([[
          {
            "errors": [
              {
                "message": "var tenant_id is unsafe",
                "code": "rego_unsafe_var_error",
                "location": {
                  "file": "src/geo.rego",
                  "row": 49,
                  "col": 3
                }
              }
            ]
          }
        ]])
        local diagnostic = parser({ output = output })
        assert.same({
            {
                row = 49,
                col = 3,
                severity = 1,
                message = "var tenant_id is unsafe",
                filename = "src/geo.rego",
                source = "opacheck",
                code = "rego_unsafe_var_error",
            },
        }, diagnostic)
    end)

    it("should not create a diagnostic without location", function()
        local output = vim.json.decode([[
          {
            "errors": [
              {
                "message": "var tenant_id is unsafe",
                "code": "rego_unsafe_var_error"
              }
            ]
          }
        ]])
        local diagnostic = parser({ output = output })
        assert.same({}, diagnostic)
    end)
end)
