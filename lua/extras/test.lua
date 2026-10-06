-- Extra "test": a test explorer (VS Code's Testing view) with neotest. Adapters:
-- Python (pytest/unittest), JavaScript/TypeScript (jest, vitest), Go, Rust
-- (needs cargo-nextest) and C/C++ (Google Test). Each adapter is loaded with
-- pcall, so one that fails does not take the others down. To add one, see
-- docs/EXTRAS.md. Keys: util/registry.lua.
return {
    {
        "nvim-neotest/neotest",
        lazy = true,
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-jest",
            "marilari88/neotest-vitest",
            "fredrikaverpil/neotest-golang",
            "rouge8/neotest-rust",
            "alfaix/neotest-gtest",
        },
        config = function()
            local adapters = {}
            local function add(name, make)
                local ok, adapter = pcall(function()
                    return make(require(name))
                end)
                if ok and adapter then
                    adapters[#adapters + 1] = adapter
                else
                    vim.schedule(function()
                        vim.notify("test extra: adapter " .. name .. " did not load:\n" .. tostring(adapter),
                            vim.log.levels.WARN)
                    end)
                end
            end

            add("neotest-python", function(m) return m end)
            add("neotest-jest", function(m) return m({ jestCommand = "npx jest" }) end)
            add("neotest-vitest", function(m) return m end)
            add("neotest-golang", function(m) return m end)
            add("neotest-rust", function(m) return m end)
            add("neotest-gtest", function(m) return m.setup({}) end)

            -- lua/user/options.lua can append adapters (the plugin itself goes in
            -- lua/user/plugins/): listen for `User LokiNeotestAdapters` and insert into
            -- require("util.extras").neotest_adapters.
            require("util.extras").neotest_adapters = adapters
            vim.api.nvim_exec_autocmds("User", { pattern = "LokiNeotestAdapters" })

            require("neotest").setup({ adapters = adapters })
            vim.api.nvim_exec_autocmds("User", { pattern = "LokiNeotestSetup" })
        end,
    },
}
