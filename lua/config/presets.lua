-- Opt-in language presets. Enable in lua/user/options.lua:
--   vim.g.loki_language_presets = { "go", "php" }
-- Each preset is a set of language-table entries (same format as languages.lua,
-- keyed by Neovim filetype). Order of precedence: languages.lua, then presets,
-- then your languages_local.lua (yours always wins).
-- Java is not here: it needs its own extra (`java`, see docs/EXTRAS.md).
-- Names below were taken from docs/ADDING_LANGUAGES.md and nvim-lspconfig / Mason
-- naming; confirm each in :Mason before relying on it.
return {
    go = {
        go = { lsp = "gopls", parser = "go", formatter = "gofumpt", tools = { "gofumpt" } },
        gomod = { parser = "gomod" },
    },
    php = {
        php = { lsp = "intelephense", parser = "php", formatter = "php_cs_fixer", tools = { "php-cs-fixer" } },
    },
    -- C#: the Neovim filetype is "cs". omnisharp needs the .NET SDK.
    csharp = {
        cs = { lsp = "omnisharp", parser = "c_sharp", formatter = "csharpier", tools = { "csharpier" } },
    },
    ruby = {
        ruby = { lsp = "ruby_lsp", parser = "ruby", formatter = "rubocop", tools = { "rubocop" } },
    },
    zig = {
        zig = { lsp = "zls", parser = "zig", formatter = "zigfmt" },
    },
}
