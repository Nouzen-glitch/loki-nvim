-- Extra "test": a test explorer (VS Code's Testing view) with neotest. Adapters for
-- Python (pytest/unittest) and JavaScript/TypeScript (jest). To add one, see
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
        },
        config = function()
            local adapters = {
                require("neotest-python"),
                require("neotest-jest")({ jestCommand = "npx jest" }),
            }
            require("neotest").setup({ adapters = adapters })
            -- Let lua/user/options.lua add adapters: listen for `User LokiNeotestSetup`.
            vim.api.nvim_exec_autocmds("User", { pattern = "LokiNeotestSetup" })
        end,
    },
}
