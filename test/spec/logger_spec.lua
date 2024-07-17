local logger = require("null-ls.logger")

describe("logger", function()
    it("get_path should return log file path from cache folder", function()
        local expected = vim.fn.stdpath("cache") .. "/" .. "null-ls.log"
        assert.equals(expected, logger:get_path())
    end)
end)
