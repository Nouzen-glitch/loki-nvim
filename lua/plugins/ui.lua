-- Colorscheme: tokyonight (night) unless vim.g.loki_colorscheme names another one,
-- for example "rose-pine-moon", "kanagawa-dragon", "moonfly" or "tokyonight-moon"
-- (set it in lua/user/options.lua). The extra themes below are lazy: nothing loads
-- until one is picked here or with :colorscheme.
local function theme_plugin(name)
    if name:find("^rose%-pine") then
        return "rose-pine"
    elseif name:find("^kanagawa") then
        return "kanagawa.nvim"
    elseif name:find("^moonfly") then
        return "moonfly"
    end
end

local function apply_colorscheme()
    local want = vim.g.loki_colorscheme or "tokyonight"
    if pcall(vim.cmd.colorscheme, want) then
        return
    end
    -- The theme may come from a lazy plugin that is not loaded yet.
    local plugin = theme_plugin(want)
    if plugin then
        pcall(function()
            require("lazy").load({ plugins = { plugin } })
        end)
        if pcall(vim.cmd.colorscheme, want) then
            return
        end
    end
    vim.v.errmsg = ""
    local hint = plugin and "\nIt is a bundled theme: restart Neovim so lazy.nvim can install it." or ""
    vim.notify(("Colorscheme '%s' not found; using tokyonight.%s"):format(want, hint), vim.log.levels.WARN)
    vim.cmd.colorscheme("tokyonight")
end

return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            apply_colorscheme()
        end,
    },

    -- Extra themes (also available as plain :colorscheme names):
    --   rose-pine, rose-pine-moon, rose-pine-dawn / kanagawa, kanagawa-dragon, kanagawa-lotus / moonfly
    { "rose-pine/neovim", name = "rose-pine", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = true },
    { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = true },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            -- Show open buffers along the top so H / L have something to look at.
            tabline = {
                lualine_a = { { "buffers", mode = 0 } },
            },
        },
    },

    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },

    {
        "nvim-tree/nvim-tree.lua",
        cmd = {
            "NvimTreeToggle",
            "NvimTreeOpen",
            "NvimTreeFindFile",
            "NvimTreeFocus",
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            view = {
                width = 32,
            },
            renderer = {
                group_empty = true,
            },
            filters = {
                dotfiles = false,
            },
        },
    },
}
