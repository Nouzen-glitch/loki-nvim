local languages = require("util.languages")

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "b0o/SchemaStore.nvim",
        },
        config = function()
            -- Servers come from config/languages.lua (+ languages_local.lua).
            -- Mason installs them; mason-lspconfig enables the ones listed in
            -- the language table through vim.lsp.enable(). Servers that merely
            -- happen to be installed in Mason (from an older setup) stay off.
            --
            -- Per-server settings go here, e.g.:
            --   vim.lsp.config("gopls", { settings = { gopls = { staticcheck = true } } })

            -- LuaLS is scoped to this Neovim configuration only.
            local nvim_config = vim.uv.fs_realpath(vim.fn.stdpath("config")) or vim.fn.stdpath("config")

            -- Completion capabilities for every server (snippets, extra edits) when
            -- nvim-cmp's source is available.
            local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
            if ok_cmp then
                vim.lsp.config("*", { capabilities = cmp_lsp.default_capabilities() })
            end

            -- JSON and YAML get validation and completion from SchemaStore
            -- (package.json, tsconfig, GitHub workflows, docker-compose, ...).
            local ok_ss, schemastore = pcall(require, "schemastore")
            if ok_ss then
                vim.lsp.config("jsonls", {
                    settings = { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } },
                })
                vim.lsp.config("yamlls", {
                    settings = {
                        yaml = {
                            schemaStore = { enable = false, url = "" },
                            schemas = schemastore.yaml.schemas(),
                        },
                    },
                })
            end

            vim.lsp.config("lua_ls", {
                root_dir = function(bufnr, on_dir)
                    local file = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(bufnr)) or ""
                    -- Compare with a trailing "/" so ~/dotfiles/nvim-old/x.lua does not match ~/dotfiles/nvim.
                    if file:sub(1, #nvim_config + 1) == nvim_config .. "/" then
                        on_dir(nvim_config)
                    end
                end,

                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            checkThirdParty = false,
                            library = { vim.env.VIMRUNTIME, nvim_config },
                        },
                        telemetry = { enable = false },
                    },
                },
            })
        end,
    },

    {
        "mason-org/mason.nvim",
        lazy = false,
        opts = {},
    },

    {
        "mason-org/mason-lspconfig.nvim",
        lazy = false,
        opts = {
            ensure_installed = languages.servers(),
            -- Only enable servers from the language table (not everything
            -- that happens to be installed in Mason).
            automatic_enable = languages.servers(),
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },

    {
        -- Installs formatters/linters listed under `tools` in languages.lua.
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        lazy = false,
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = languages.tools(),
        },
    },

    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        opts = {},
    },
}
