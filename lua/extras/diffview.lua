-- Extra "diffview": VS Code's Source Control diff editor and Timeline, plus a
-- 3-way merge tool for conflicts (diffview.nvim). Keys live in util/registry.lua.
return {
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewRefresh" },
        dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
        opts = {
            enhanced_diff_hl = true,
        },
    },
}
