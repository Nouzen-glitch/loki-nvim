-- Personal keymaps. Loaded right after config/keymaps.lua.

-- Enter between a pair ({|}) opens an indented block, like VS Code.
-- nvim-cmp's <CR> falls back to this when no completion item is selected.
vim.keymap.set("i", "<CR>", function()
    return require("mini.pairs").cr()
end, { expr = true, replace_keycodes = false, desc = "Newline (open pair block)" })
