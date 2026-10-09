local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight the yanked text briefly.
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Reopen a file at the position where you last left it.
vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if vim.bo[args.buf].buftype ~= "" or ft == "gitcommit" or ft == "gitrebase" or ft == "help" then
            return
        end
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Reload files that changed on disk (git checkout, formatters, other tools).
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = group,
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- Create missing parent folders when saving to a new path.
vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    callback = function(args)
        if args.match:match("^%w%w+:[\\/][\\/]") then
            return -- remote/URL buffers
        end
        vim.fn.mkdir(vim.fn.fnamemodify(args.file, ":p:h"), "p")
    end,
})

-- Filetype plugins (yaml, json, html, ...) set their own indent after your options.
-- Re-apply the global shiftwidth / tabstop / softtabstop to normal file buffers, so
-- the value you set (default 4) is what you get. A project's .editorconfig still wins.
-- Opt out: vim.g.loki_ftplugin_indent = true in lua/user/options.lua.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
        if vim.g.loki_ftplugin_indent or vim.bo[args.buf].buftype ~= "" then
            return
        end
        local ec = vim.b[args.buf].editorconfig
        if type(ec) == "table" and (ec.indent_size or ec.tab_width or ec.indent_style) then
            return
        end
        vim.bo[args.buf].shiftwidth = vim.go.shiftwidth
        vim.bo[args.buf].tabstop = vim.go.tabstop
        vim.bo[args.buf].softtabstop = vim.go.softtabstop
    end,
})

-- Show diagnostics as virtual text, but keep them visually restrained.
vim.diagnostic.config({
    virtual_text = {
        spacing = 2,
        source = "if_many",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "if_many",
    },
})

-- LSP keys (K, gd, gr, ...) are attached per buffer when a server attaches.
require("util.lsp").setup()

-- `nvim some/folder` (or `nvim .`): netrw is disabled, so open the file explorer
-- for the folder instead of showing an empty directory buffer.
vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
        if vim.fn.argc() ~= 1 or #vim.api.nvim_list_uis() == 0 then
            return
        end
        local dir = vim.fn.argv(0)
        if vim.fn.isdirectory(dir) ~= 1 then
            return
        end
        vim.cmd.cd(vim.fn.fnameescape(dir))
        -- Replace the directory buffer with an empty one, then show the tree.
        vim.cmd("enew")
        pcall(vim.cmd, "bwipeout #")
        require("nvim-tree.api").tree.open({ path = vim.fn.getcwd() })
    end,
})

-- Tree-sitter folding, opt-in: vim.g.loki_treesitter_folding = true in
-- lua/user/options.lua. Folds start open; za toggles, zR opens all, zM closes all.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
        if not vim.g.loki_treesitter_folding then
            return
        end
        if vim.bo[args.buf].buftype ~= "" then
            return
        end
        if not pcall(vim.treesitter.get_parser, args.buf) then
            return
        end
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldlevel = 99
    end,
})

-- Quit Neovim when the file explorer is the only window left.
vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    nested = true,
    callback = function()
        if vim.bo.filetype == "NvimTree" and #vim.api.nvim_list_wins() == 1 then
            pcall(vim.cmd, "quit")
        end
    end,
})
