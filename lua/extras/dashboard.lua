-- Extra "dashboard": start screen shown only for a bare `nvim` (alpha skips it
-- when files or stdin are given). Buttons for the "sessions" extra appear only
-- when that extra is enabled.
return {
    {
        "goolord/alpha-nvim",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local d = require("alpha.themes.dashboard")
            d.section.header.val = { "L O K I   N E O V I M" }

            local buttons = {
                d.button("f", "  Find file", "<cmd>Telescope find_files<cr>"),
                d.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
            }
            if require("util.extras").is_enabled("sessions") then
                table.insert(buttons, d.button("s", "  Restore session", '<cmd>lua require("persistence").load()<cr>'))
            end
            vim.list_extend(buttons, {
                d.button("h", "  Guide", "<cmd>LokiHelp<cr>"),
                d.button("t", "  Tutorial", "<cmd>LokiTutor<cr>"),
                d.button("l", "󰒲  Plugins", "<cmd>Lazy<cr>"),
                d.button("q", "  Quit", "<cmd>qa<cr>"),
            })
            d.section.buttons.val = buttons
            alpha.setup(d.config)
        end,
    },
}
