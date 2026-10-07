return {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- These are plain `opts`, so you can change them from lua/user/plugins/
    -- without editing this file, e.g. to rebind the toggle key:
    --   { "akinsho/toggleterm.nvim", opts = { open_mapping = [[<C-t>]] } }
    opts = {
        size = 15, -- Height of the bottom terminal pane
        open_mapping = [[<C-\>]], -- Toggle terminal (Ctrl + \)
        direction = "horizontal", -- Opens at the bottom of the editor
        shade_terminals = true, -- Darkens the terminal background slightly
        start_in_insert = true, -- Enter terminal mode when opened
        insert_mappings = true, -- Keep open_mapping working in insert mode
        terminal_mappings = true, -- Keep open_mapping working in terminal mode
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)

        -- Keys that only exist inside toggleterm buffers. Other terminals
        -- (:terminal running lazygit, fzf, vim...) keep every key for the program.
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("LokiTerminal", { clear = true }),
            pattern = "toggleterm",
            callback = function(args)
                -- Descriptions come from util/registry.lua (one source of truth).
                local registry = require("util.registry")
                local function t(lhs, rhs)
                    vim.keymap.set("t", lhs, rhs, { buffer = args.buf, desc = registry.desc("t", lhs) })
                end
                -- Esc and jk switch to Normal mode (scroll, search, window navigation).
                t("jk", [[<C-\><C-n>]])
                t("<Esc>", [[<C-\><C-n>]])
                -- Move out of the terminal window.
                t("<C-h>", [[<C-\><C-n><C-w>h]])
                t("<C-j>", [[<C-\><C-n><C-w>j]])
                t("<C-k>", [[<C-\><C-n><C-w>k]])
                t("<C-l>", [[<C-\><C-n><C-w>l]])
            end,
        })
    end,
}
