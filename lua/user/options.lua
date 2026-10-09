-- Personal options. Loaded right after config/options.lua, so these win.

-- Neovim's own ftplugins force their "recommended" indent on top of shiftwidth.
-- Switch that off so the global shiftwidth = 4 applies.
vim.g.lua_recommended_style = 0
vim.g.python_recommended_style = 0
vim.g.rust_recommended_style = 0
vim.g.vim_recommended_style = 0
vim.g.zig_recommended_style = 0

-- Catch-all for filetypes with no switch (yaml, json, html, css, ...).
vim.api.nvim_create_autocmd("FileType", {
    desc = "Use 4-space indent for every filetype",
    callback = function()
        vim.bo.shiftwidth = 4
        vim.bo.tabstop = 4
        vim.bo.softtabstop = 4
    end,
})
