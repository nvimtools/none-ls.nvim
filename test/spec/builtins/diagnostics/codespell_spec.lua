local stub = require("luassert.stub")

local diagnostics = require("null-ls.builtins").diagnostics
local loop = require("null-ls.loop")

describe("diagnostics codespell", function()
    describe("on_output", function()
        local parser = diagnostics.codespell._opts.on_output

        it("should create a diagnostic from codespell output", function()
            local result
            parser({
                content = { "# adn" },
                output = "1: # adn\n\tadn ==> and\n",
            }, function(parsed)
                result = parsed
            end)

            assert.same({
                {
                    row = 1,
                    col = 3,
                    end_col = 6,
                    source = "codespell",
                    message = "adn ==> and",
                    severity = 2,
                },
            }, result)
        end)

        it("should create multiple diagnostics across lines", function()
            local result
            parser({
                content = { "local adn = 1", "local ok = true", "-- teh end" },
                output = "1: local adn = 1\n\tadn ==> and\n3: -- teh end\n\tteh ==> the\n",
            }, function(parsed)
                result = parsed
            end)

            assert.same({
                {
                    row = 1,
                    col = 7,
                    end_col = 10,
                    source = "codespell",
                    message = "adn ==> and",
                    severity = 2,
                },
                {
                    row = 3,
                    col = 4,
                    end_col = 7,
                    source = "codespell",
                    message = "teh ==> the",
                    severity = 2,
                },
            }, result)
        end)

        it("should escape lua pattern characters in misspelled word", function()
            local result
            parser({
                content = { "local x = 'foo%bar'" },
                output = "1: local x = 'foo%bar'\n\tfoo%bar ==> foobar\n",
            }, function(parsed)
                result = parsed
            end)

            assert.same({
                {
                    row = 1,
                    col = 12,
                    end_col = 19,
                    source = "codespell",
                    message = "foo%bar ==> foobar",
                    severity = 2,
                },
            }, result)
        end)

        it("should fall back to column 0 when misspelled word is not found in line", function()
            local result
            parser({
                content = { "line without match" },
                output = "1: truncated...\n\tmisspeled ==> misspelled\n",
            }, function(parsed)
                result = parsed
            end)

            assert.same({
                {
                    row = 1,
                    col = 0,
                    end_col = 1,
                    source = "codespell",
                    message = "misspeled ==> misspelled",
                    severity = 2,
                },
            }, result)
        end)

        it("should handle empty and nil output", function()
            local done = stub.new()

            parser({ content = { "# and" }, output = nil }, done)
            assert.stub(done).was_called(1)
            assert.equals(nil, done.calls[1].refs[1])

            done:clear()

            parser({ content = { "# and" }, output = "" }, done)
            assert.stub(done).was_called(1)
            assert.same({}, done.calls[1].refs[1])
        end)
    end)

    describe("generator", function()
        local spawn
        local done

        before_each(function()
            spawn = stub(loop, "spawn")
            done = stub.new()
        end)

        after_each(function()
            spawn:revert()
            done:clear()
        end)

        it("should accept exit codes 0 and 65 and reject others", function()
            diagnostics.codespell.generator.fn({ content = { "# adn" } }, done)

            assert.stub(spawn).was_called(1)
            local spawn_opts = spawn.calls[1].refs[3]
            assert.equals(true, spawn_opts.check_exit_code(0))
            assert.equals(true, spawn_opts.check_exit_code(65))
            assert.equals(false, spawn_opts.check_exit_code(1))
            assert.equals(false, spawn_opts.check_exit_code(64))
        end)

        it("should return diagnostics in --count mode when stderr has count", function()
            local codespell = diagnostics.codespell.with({ extra_args = { "--count" } })
            codespell.generator.fn({ content = { "# adn" } }, done)

            assert.stub(spawn).was_called(1)
            assert.same({ "--count", "-" }, spawn.calls[1].refs[2])

            local handler = spawn.calls[1].refs[3].handler
            handler("1\n", "1: # adn\n\tadn ==> and\n")

            assert.stub(done).was_called(1)
            assert.same({
                {
                    row = 1,
                    col = 3,
                    end_col = 6,
                    source = "codespell",
                    message = "adn ==> and",
                    severity = 2,
                },
            }, done.calls[1].refs[1])
        end)

        it("should handle --count mode with zero errors", function()
            local codespell = diagnostics.codespell.with({ extra_args = { "--count" } })
            codespell.generator.fn({ content = { "# and" } }, done)

            assert.stub(spawn).was_called(1)
            local handler = spawn.calls[1].refs[3].handler
            handler("0\n", nil)

            assert.stub(done).was_called(1)
            assert.equals(nil, done.calls[1].refs[1])
        end)

        it("should return diagnostics in normal mode without --count", function()
            diagnostics.codespell.generator.fn({ content = { "# adn" } }, done)

            assert.stub(spawn).was_called(1)
            assert.same({ "-" }, spawn.calls[1].refs[2])

            local handler = spawn.calls[1].refs[3].handler
            handler(nil, "1: # adn\n\tadn ==> and\n")

            assert.stub(done).was_called(1)
            assert.same({
                {
                    row = 1,
                    col = 3,
                    end_col = 6,
                    source = "codespell",
                    message = "adn ==> and",
                    severity = 2,
                },
            }, done.calls[1].refs[1])
        end)
    end)
end)
