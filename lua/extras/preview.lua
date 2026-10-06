-- Extra "preview": Markdown in the browser (works in any terminal that has a
-- browser) and images inside the terminal (kitty graphics protocol: kitty,
-- WezTerm, Ghostty; needs ImageMagick). image.nvim is only loaded when the
-- terminal looks capable (util/extras.lua:can_render_images), so everywhere else
-- the extra is a clean no-op. Keys: util/registry.lua.
return {
    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
    },
    {
        "3rd/image.nvim",
        cond = function()
            return require("util.extras").can_render_images()
        end,
        event = "VeryLazy",
        opts = {
            backend = "kitty",
            -- ImageMagick command line: no luarocks needed (rocks are off in config/lazy.lua).
            processor = "magick_cli",
        },
    },
}
