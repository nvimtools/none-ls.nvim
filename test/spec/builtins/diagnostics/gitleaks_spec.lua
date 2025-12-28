local diagnostics = require("null-ls.builtins").diagnostics

describe("diagnostics gitleaks", function()
    local parser = diagnostics.gitleaks._opts.on_output

    it("should create a diagnostic from gitleaks output", function()
        local output = vim.json.decode([[
          [
            {
              "RuleID": "generic-api-key",
              "Description": "Detected a Generic API Key, potentially exposing access to various services and sensitive operations.",
              "StartLine": 192,
              "EndLine": 192,
              "StartColumn": 8,
              "EndColumn": 67,
              "Match": "ocp-apim-subscription-key: 5ccb5b137e7444d885be752eda7f767a'",
              "Secret": "5ccb5b137e7444d885be752eda7f767a",
              "File": "zsh/zsh.d/functions.zsh",
              "SymlinkFile": "",
              "Commit": "",
              "Entropy": 3.5695488,
              "Author": "",
              "Email": "",
              "Date": "",
              "Message": "",
              "Tags": [],
              "Fingerprint": "zsh/zsh.d/functions.zsh:generic-api-key:192"
            }
          ]
        ]])
        local diagnostic = parser({ output = output })
        assert.same({
            {
                row = 192,
                col = 8,
                end_row = 192,
                end_col = 67,
                message = "Detected a Generic API Key, potentially exposing access to various services and sensitive operations.",
                source = "gitleaks",
                code = "generic-api-key",
            },
        }, diagnostic)
    end)

    it("should handle multiple findings", function()
        local output = vim.json.decode([[
          [
            {
              "RuleID": "generic-api-key",
              "Description": "Detected a Generic API Key, potentially exposing access to various services and sensitive operations.",
              "StartLine": 10,
              "EndLine": 10,
              "StartColumn": 5,
              "EndColumn": 30,
              "Match": "api_key = 'abc123'",
              "Secret": "abc123",
              "File": "config.py",
              "Fingerprint": "config.py:generic-api-key:10"
            },
            {
              "RuleID": "aws-access-token",
              "Description": "Detected AWS Access Token, risking unauthorized cloud resource access and data breaches.",
              "StartLine": 25,
              "EndLine": 25,
              "StartColumn": 12,
              "EndColumn": 50,
              "Match": "AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI",
              "Secret": "wJalrXUtnFEMI",
              "File": "env.sh",
              "Fingerprint": "env.sh:aws-access-token:25"
            }
          ]
        ]])
        local diagnostic = parser({ output = output })
        assert.same({
            {
                row = 10,
                col = 5,
                end_row = 10,
                end_col = 30,
                message = "Detected a Generic API Key, potentially exposing access to various services and sensitive operations.",
                source = "gitleaks",
                code = "generic-api-key",
            },
            {
                row = 25,
                col = 12,
                end_row = 25,
                end_col = 50,
                message = "Detected AWS Access Token, risking unauthorized cloud resource access and data breaches.",
                source = "gitleaks",
                code = "aws-access-token",
            },
        }, diagnostic)
    end)

    it("should handle empty output", function()
        local output = vim.json.decode("[]")
        local diagnostic = parser({ output = output })
        assert.same({}, diagnostic)
    end)

    it("should handle nil output", function()
        local diagnostic = parser({ output = nil })
        assert.same({}, diagnostic)
    end)
end)
