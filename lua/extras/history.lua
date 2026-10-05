-- Extra "history": a visual undo tree, like VS Code's Timeline for the current file.
-- Persistent undo is already on (options.lua: undofile), so history survives restarts.
-- Keys: util/registry.lua.
return {
    {
        "mbbill/undotree",
        cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide", "UndotreeFocus" },
        init = function()
            vim.g.undotree_SetFocusWhenToggle = 1
        end,
    },
}
