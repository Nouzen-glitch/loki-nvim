-- Editor behavior / appearance.
-- Keep this file deliberately boring: editor fundamentals only.
-- To change any of this for yourself, use lua/user/options.lua (see docs/MIGRATING.md).

vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Neovim's own ftplugins force their "recommended" indent (2 spaces for Lua,
-- Python's own rules, ...) on top of shiftwidth. Switch that off so the
-- shiftwidth above applies; autocmds.lua covers filetypes with no such switch.
-- Keep a language's own style: vim.g.loki_ftplugin_indent = true in lua/user/options.lua.
if not vim.g.loki_ftplugin_indent then
    for _, lang in ipairs({ "lua", "python", "rust", "vim", "zig" }) do
        vim.g[lang .. "_recommended_style"] = 0
    end
end
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.clipboard = "unnamedplus"

-- Faster, more readable command-line feedback.
vim.opt.showmode = false
vim.opt.laststatus = 3

-- Small comforts.
vim.opt.confirm = true -- ask instead of failing on :q with unsaved changes
vim.opt.inccommand = "split" -- live preview for :s substitutions
vim.opt.winborder = "rounded" -- consistent borders on floating windows (0.11+)

-- Folds are manual: zf creates one, za toggles it. Automatic tree-sitter folding is
-- opt-in: vim.g.loki_treesitter_folding = true in lua/user/options.lua.
vim.opt.foldmethod = "manual"

-- Arrow keys are disabled on purpose to learn real Vim movement.
-- Turn that off in lua/user/options.lua with:  vim.g.loki_disable_arrows = false

-- Disable the mouse if you want a completely keyboard-only editor:
-- vim.opt.mouse = ""

-- netrw is disabled because nvim-tree is used as the explorer.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
