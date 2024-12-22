local stub = require("luassert.stub")

function call_sync(async_fn, arg)
    local co = coroutine.running()
    assert(co, "not running inside a coroutine")

    local val = nil
    async_fn(
        arg,
        vim.schedule_wrap(function(result)
            val = result
            coroutine.resume(co)
        end)
    )
    coroutine.yield()

    return val
end

describe("cache", function()
    local cache = require("null-ls.helpers").cache
    after_each(function()
        cache._reset()
    end)

    describe("by_bufnr", function()
        local mock_params = { bufnr = 1 }
        local mock_val = "mock_val"
        local mock_cb = stub.new()
        before_each(function()
            mock_cb.returns(mock_val)
        end)
        after_each(function()
            mock_cb:clear()
        end)

        it("should call cb with params", function()
            local fn = cache.by_bufnr(mock_cb)

            fn(mock_params)

            assert.stub(mock_cb).was_called_with(mock_params)
        end)

        it("should return cb return value", function()
            local fn = cache.by_bufnr(mock_cb)

            local val = fn(mock_params)

            assert.equals(val, "mock_val")
        end)

        it("should return false if cb returns nil", function()
            mock_cb.returns(nil)
            local fn = cache.by_bufnr(mock_cb)

            local val = fn(mock_params)

            assert.equals(val, false)
        end)

        it("should return cached value", function()
            local fn = cache.by_bufnr(mock_cb)
            local val = fn(mock_params)

            mock_cb.returns("other_val")
            val = fn(mock_params)

            assert.equals(val, "mock_val")
        end)

        it("should only call cb once if bufnr is the same", function()
            local fn = cache.by_bufnr(mock_cb)

            fn(mock_params)
            fn(mock_params)

            assert.stub(mock_cb).was_called(1)
        end)

        it("should only call cb once if cb returns false", function()
            mock_cb.returns(false)
            local fn = cache.by_bufnr(mock_cb)

            fn(mock_params)
            fn(mock_params)

            assert.stub(mock_cb).was_called(1)
        end)

        it("should call cb twice if bufnr is different", function()
            local fn = cache.by_bufnr(mock_cb)

            fn(mock_params)
            fn({ bufnr = 2 })

            assert.stub(mock_cb).was_called(2)
        end)
    end)

    describe("by_bufnr_async", function()
        local mock_params = { bufnr = 1 }
        local mock_val = "mock_val"
        local invoked_params = {}
        local mock_cb = function(params, done)
            vim.defer_fn(function()
                table.insert(invoked_params, params)
                done(mock_val)
            end, 0)
        end
        after_each(function()
            mock_val = "mock_val"
            invoked_params = {}
        end)

        it("should call cb with params", function()
            local fn = cache.by_bufnr_async(mock_cb)

            call_sync(fn, mock_params)

            assert.are.same({ mock_params }, invoked_params)
        end)

        it("should return cb return value", function()
            local fn = cache.by_bufnr_async(mock_cb)

            local val = call_sync(fn, mock_params)

            assert.equals("mock_val", val)
        end)

        it("should return false if cb returns nil", function()
            mock_val = nil
            local fn = cache.by_bufnr_async(mock_cb)

            local val = call_sync(fn, mock_params)

            assert.equals(false, val)
        end)

        it("should return cached value", function()
            local co = coroutine.running()
            assert(co, "not running inside a coroutine")

            local fn = cache.by_bufnr_async(mock_cb)

            local val = call_sync(fn, mock_params)
            assert.equals("mock_val", val)

            -- Change the return value for the uncached function, and invoke
            -- the cached function. We shouldn't see the change.
            mock_val = "other_val"
            val = call_sync(fn, mock_params)

            assert.equals("mock_val", val)
        end)

        it("should only call cb once if bufnr is the same", function()
            local fn = cache.by_bufnr_async(mock_cb)

            call_sync(fn, mock_params)
            call_sync(fn, mock_params)

            assert.are.same({ mock_params }, invoked_params)
        end)

        it("should only call cb once if cb returns false", function()
            mock_val = false
            local fn = cache.by_bufnr_async(mock_cb)

            call_sync(fn, mock_params)
            call_sync(fn, mock_params)

            assert.are.same({ mock_params }, invoked_params)
        end)

        it("should call cb twice if bufnr is different", function()
            local fn = cache.by_bufnr_async(mock_cb)

            call_sync(fn, mock_params)
            call_sync(fn, { bufnr = 2 })

            assert.are.same({ mock_params, { bufnr = 2 } }, invoked_params)
        end)
    end)
end)
