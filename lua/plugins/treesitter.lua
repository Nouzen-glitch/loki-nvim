return {
    {
        "nvim-treesitter/nvim-treesitter",
        -- Upstream's `main` branch is an incompatible rewrite that needs Neovim 0.12 and
        -- the tree-sitter CLI; `master` is locked and kept for Neovim 0.11.
        -- Migration plan: docs/TREESITTER_MIGRATION.md.
        branch = "master",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- Parsers come from config/languages.lua (+ languages_local.lua),
            -- plus the ones the enabled extras need (sql, http, dockerfile).
            local parsers = require("util.languages").parsers()
            local extras = require("util.extras")
            for _, name in ipairs(extras.enabled()) do
                vim.list_extend(parsers, extras.registry[name].parsers or {})
            end
            require("nvim-treesitter.configs").setup({
                ensure_installed = parsers,
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
                -- Fetch a parser on demand when you open an unlisted filetype
                -- (highlighting only, no LSP). Set to false to install only listed parsers.
                auto_install = true,
            })
        end,
    },
}
