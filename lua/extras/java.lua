-- Extra "java": jdtls through nvim-jdtls. Java is not a plain language-table line
-- because jdtls needs a per-project workspace folder and is started per buffer by
-- the plugin, not by vim.lsp.enable. Mason installs the `jdtls` package. The LSP
-- keys (gd, gr, K, ...) attach through the normal LspAttach step; formatting uses
-- the server (<leader>cf falls back to LSP).
return {
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
        config = function()
            local function start()
                local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
                local cmd = (vim.fn.executable(mason_bin) == 1 and mason_bin)
                    or (vim.fn.executable("jdtls") == 1 and "jdtls")
                    or nil
                if not cmd then
                    vim.notify("jdtls is not installed yet. Open :Mason (package `jdtls`) or restart Neovim.",
                        vim.log.levels.WARN)
                    return
                end
                local root = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
                    or vim.fn.getcwd()
                -- One workspace folder per project, under the cache (follows NVIM_APPNAME).
                local workspace = vim.fn.stdpath("cache") .. "/jdtls/"
                    .. vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 8)
                local config = { cmd = { cmd, "-data", workspace }, root_dir = root }
                local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
                if ok_cmp then
                    config.capabilities = cmp_lsp.default_capabilities()
                end
                require("jdtls").start_or_attach(config)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("LokiJava", { clear = true }),
                pattern = "java",
                callback = start,
            })
            -- The plugin loads on the first java buffer, after its FileType event.
            if vim.bo.filetype == "java" then
                start()
            end
        end,
    },

    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "jdtls" })
        end,
    },
}
