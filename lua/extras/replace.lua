-- Extra "replace": search and replace across the whole project with a live,
-- editable results buffer (VS Code's Ctrl+Shift+H). Uses ripgrep. Keys: util/registry.lua.
return {
    {
        "MagicDuck/grug-far.nvim",
        cmd = { "GrugFar", "GrugFarWithin" },
        opts = {},
    },
}
