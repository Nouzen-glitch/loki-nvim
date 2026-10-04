-- Default language support. The ONLY place language settings live.
-- Each key is a Neovim filetype. Every field is optional; omit what you don't want.
--
--   lsp       lspconfig server name (installed via Mason)   e.g. "clangd"
--   parser    Tree-sitter parser name(s)                    e.g. "c" or { "markdown", "markdown_inline" }
--   formatter Conform formatter name(s)                     e.g. "clang_format"
--   linter    nvim-lint linter name(s); only used while the "lint" extra is enabled
--             e.g. "ruff"
--   tools     Mason PACKAGE names to install (formatters/linters); names can differ
--             from the Conform name, e.g. clang_format -> "clang-format".
--             Skip if the tool ships elsewhere (rustfmt comes with rustup).
--
-- To add your own languages WITHOUT editing this file, use
-- lua/config/languages_local.lua (see languages_local.lua.example).
-- Full guide: docs/ADDING_LANGUAGES.md

return {
    c   = { lsp = "clangd", parser = "c",   formatter = "clang_format", tools = { "clang-format" } },
    cpp = { lsp = "clangd", parser = "cpp", formatter = "clang_format", tools = { "clang-format" } },

    python = { lsp = "basedpyright", parser = "python", formatter = "ruff_format", linter = "ruff", tools = { "ruff" } },

    -- lua_ls is scoped to the Neovim config only (see plugins/lsp.lua).
    lua = { lsp = "lua_ls", parser = "lua", formatter = "stylua", tools = { "stylua" } },

    rust = { lsp = "rust_analyzer", parser = "rust", formatter = "rustfmt" },

    sh   = { lsp = "bashls", parser = "bash", formatter = "shfmt", linter = "shellcheck", tools = { "shfmt", "shellcheck" } },
    bash = { parser = "bash", formatter = "shfmt", linter = "shellcheck", tools = { "shfmt", "shellcheck" } },

    javascript      = { lsp = "ts_ls", parser = "javascript", formatter = "prettier", tools = { "prettier" } },
    javascriptreact = { parser = "javascript", formatter = "prettier", tools = { "prettier" } },
    typescript      = { lsp = "ts_ls", parser = "typescript", formatter = "prettier", tools = { "prettier" } },
    typescriptreact = { parser = "tsx", formatter = "prettier", tools = { "prettier" } },

    json     = { parser = "json", formatter = "prettier", tools = { "prettier" } },
    yaml     = { parser = "yaml", formatter = "prettier", tools = { "prettier" } },
    markdown = { parser = { "markdown", "markdown_inline" }, formatter = "prettier", tools = { "prettier" } },

    vim = { parser = { "vim", "vimdoc" } },
}
