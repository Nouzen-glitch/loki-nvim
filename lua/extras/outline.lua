-- Extra "outline": symbol outline sidebar (VS Code's Outline view) from LSP or
-- tree-sitter, and a breadcrumb-like jump list. Keys: util/registry.lua.
return {
    {
        "stevearc/aerial.nvim",
        -- aerial's `master` needs Neovim 0.12; this config supports 0.11+. Switch to
        -- master (remove this line) once 0.12 is the minimum.
        branch = "nvim-0.11",
        cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {
            backends = { "lsp", "treesitter", "markdown", "man" },
            layout = { default_direction = "right", min_width = 28 },
            show_guides = true,
        },
    },
}
