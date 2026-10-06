-- Extra "github": pull requests and issues from inside Neovim (octo.nvim).
-- Needs the `gh` CLI, authenticated (`gh auth login`). The token stays in gh's
-- own store; nothing is kept in lua/user/. Keys: util/registry.lua.
return {
    {
        "pwntester/octo.nvim",
        cmd = "Octo",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            picker = "telescope",
        },
    },
}
