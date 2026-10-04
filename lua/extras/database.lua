-- Extra "database": vim-dadbod UI. Connection strings are secrets: keep them in
-- environment variables (DBUI_URL) or in the folder below, never in a tracked file.
return {
    {
        "kristijanhusak/vim-dadbod-ui",
        cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
        dependencies = {
            { "tpope/vim-dadbod", lazy = true },
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        },
        init = function()
            vim.g.db_ui_use_nerd_fonts = 1
            -- stdpath follows NVIM_APPNAME, so alongside installs stay separate.
            vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
            -- SQL completion for SQL buffers only; the shipped cmp sources stay as they are.
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("LokiDadbod", { clear = true }),
                pattern = { "sql", "mysql", "plsql" },
                callback = function()
                    require("cmp").setup.buffer({
                        sources = {
                            { name = "vim-dadbod-completion" },
                            { name = "buffer" },
                        },
                    })
                end,
            })
        end,
    },
}
