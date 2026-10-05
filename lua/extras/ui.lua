-- Extra "ui": two VS Code defaults that Neovim lacks. Indent guides, and "sticky
-- scroll" (the function or class you are inside stays pinned at the top).
-- No keys; :TSContextToggle and :IBLToggle switch them for the session.
return {
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = { char = "│" },
            scope = { enabled = false },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            max_lines = 3,
            multiline_threshold = 1,
        },
    },
}
