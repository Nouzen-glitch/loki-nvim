return {
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- Built from config/languages.lua (+ languages_local.lua).
            formatters_by_ft = require("util.languages").formatters_by_ft(),

            format_on_save = function(bufnr)
                -- :LokiFormat off turns format on save off for this session.
                if vim.g.loki_format_on_save == false then
                    return
                end
                -- Disable automatic formatting for huge files.
                local max_size = 200 * 1024 -- 200 KB
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
                if ok and stats and stats.size > max_size then
                    return
                end
                return {
                    timeout_ms = 1000,
                    lsp_format = "fallback",
                }
            end,
        },
    },
}
