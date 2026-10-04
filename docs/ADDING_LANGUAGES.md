# Adding a Language

Nothing is installed unless a language is listed. Language support lives in
one table, and adding a language is one line.

| File | Role |
| --- | --- |
| `lua/config/languages.lua` | Defaults shipped with the config |
| `lua/config/languages_local.lua` | **Your additions.** Optional; you create it (gitignored) |
| `lua/util/languages.lua` | Turns the table into server/parser/formatter/tool lists (never edit) |

The table feeds `plugins/lsp.lua` (servers, mason-tool-installer),
`plugins/treesitter.lua` and `plugins/formatting.lua`. You should not need to
edit those.

Inside Neovim, `:LokiEdit languages` creates and opens an empty `languages_local.lua` for you.
It is not in git: back it up with `:LokiBackup` (see [MIGRATING.md](MIGRATING.md)).

Prefer `languages_local.lua`: your languages stay separate from the defaults.
From inside the config folder, start from the template:

```bash
cp lua/config/languages_local.lua.example lua/config/languages_local.lua
```

## Quick version

1. Add a line to `languages_local.lua`.
2. Quit and reopen Neovim. Missing servers, tools and parsers install
   themselves (watch `:Mason`).
3. Open a file of that language and verify (below).

## 1. Prerequisites

Mason downloads or builds tools with your system toolchains. Install what
your languages need first (`:checkhealth loki` shows what is missing):

| Needed for | Install |
| --- | --- |
| Most servers (`ts_ls`, `html`, `cssls`, `jsonls`, `yamlls`) and `prettier` | Node.js and npm |
| `basedpyright`, `ruff` | Python 3 with `venv` |
| `gopls`, `gofumpt` | Go |
| `rustfmt` | rustup (not a Mason package) |

```bash
# Fedora
sudo dnf install nodejs npm python3 golang
```

## 2. Entry format

The key is a Neovim **filetype** (`:set filetype?` in an open file). Every
field is optional and takes a string or a list.

```lua
go = { lsp = "gopls", parser = "go", formatter = "gofumpt", tools = { "gofumpt" } },
```

| Field | Meaning | How to look it up |
| --- | --- | --- |
| `lsp` | Language server, **lspconfig name** | `:help lspconfig-all`, or the nvim-lspconfig repo's `lsp/` folder |
| `parser` | Tree-sitter parser(s): highlighting and indent | `:TSInstallInfo` |
| `formatter` | Conform formatter(s), run in order | `:help conform-formatters` |
| `tools` | **Mason package** names to auto-install (formatters, linters) | `:Mason`, then `<C-f>` to filter |

Three naming systems: `lsp` uses lspconfig names (`ts_ls`, `lua_ls`, not the
Mason package `typescript-language-server`), `formatter` uses Conform names
(`clang_format`), and `tools` uses Mason package names (`clang-format`).

Leave out what you don't want: `{ parser = "toml" }` is highlight-only.

## 3. Worked example: PHP

1. Filetype: `:set ft?` in a `.php` file shows `php`.
2. Server: `:help lspconfig-all` lists `intelephense`.
3. Parser: `:TSInstallInfo` shows `php`.
4. Formatter: `:help conform-formatters` lists `php_cs_fixer`; its Mason
   package (`:Mason`) is `php-cs-fixer`.
5. Add it and restart Neovim:

```lua
php = { lsp = "intelephense", parser = "php", formatter = "php_cs_fixer", tools = { "php-cs-fixer" } },
```

Unsure of a name? Add only what you know (for example just `parser`), confirm
that works, then add the rest.

## 4. Common names (verify in `:Mason`)

| Language | Filetype | `lsp` | `parser` | `formatter` (`tools`) |
| --- | --- | --- | --- | --- |
| Go | `go` | `gopls` | `go` | `gofumpt` (`gofumpt`) |
| HTML | `html` | `html` | `html` | `prettier` (`prettier`) |
| CSS | `css` | `cssls` | `css` | `prettier` |
| TOML | `toml` | `taplo` | `toml` | `taplo` (`taplo`) |
| Docker | `dockerfile` | `dockerls` | `dockerfile` | none |
| Zig | `zig` | `zls` | `zig` | `zigfmt` |
| Ruby | `ruby` | `ruby_lsp` | `ruby` | `rubocop` (`rubocop`) |

## 5. Verify

| Check | Command | Expect |
| --- | --- | --- |
| Server installed | `:Mason` | Listed with a check mark |
| Server attached | `:checkhealth vim.lsp` | Server listed for this buffer |
| Highlighting | `:InspectTree` | A tree, not an error |
| Formatter | `:ConformInfo` | Your formatter shown as ready |
| Missing tools | `:MasonToolsInstall` | Installs anything not yet installed |

Also try `K`, `gd`, `<leader>cf` and completion.

## 6. Changing and removing

- **Replace a default:** use the same filetype key in `languages_local.lua`;
  yours wins.
- **Disable a default:** `rust = false,`
- **Uninstall:** removing an entry stops that server from being enabled, but
  does not delete anything. Run `:Mason` and press `X` on the package to remove
  it from disk. Servers that are installed in Mason but not in the table stay
  off.
- **Server settings:** put `vim.lsp.config("gopls", { settings = { gopls = { staticcheck = true } } })`
  in `lua/user/options.lua` (yours, survives updates). Editing `plugins/lsp.lua` makes `scripts/update.sh` stop.

## 7. Special cases

**Server not in Mason.** Install it yourself, then add this to
`lua/user/options.lua` (not `plugins/lsp.lua`: editing shipped files blocks updates):

```lua
vim.lsp.config("myserver", {
    cmd = { "myserver", "--stdio" },
    filetypes = { "myft" },
    root_markers = { ".git" },
})
vim.lsp.enable("myserver")
```

**Java.** `jdtls` needs the `nvim-jdtls` plugin and per-project setup, so a
plain `lsp = "jdtls"` is not enough.

**Formatter not in Mason** (`rustfmt`, `gofmt`): leave `tools` out and
install it with the language's own toolchain.

**Debugging (DAP) and linters** are not part of this table.

## 8. Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| Server missing in `:Mason` | Wrong lspconfig name in `lsp`, or missing Node/Python/Go (section 1); read `:MasonLog` |
| Installed but not attached | Wrong filetype key (`:set ft?`), not in the language table, or file is outside a project root the server recognises |
| `<leader>cf` does nothing | Formatter not installed (`:ConformInfo`) or wrong Conform name |
| No colors | Wrong parser name (`:TSInstallInfo`), or run `:checkhealth nvim-treesitter` |
| Highlighting but no IntelliSense | Only a parser is listed (or `auto_install` fetched it); add `lsp` |
| `languages_local.lua error` on startup | Syntax error: check commas and braces |
