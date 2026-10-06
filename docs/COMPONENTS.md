# Components

Paths are relative to `lua/`. Plugin specs live in `plugins/`.

## Plugins

| Component | Purpose | Configured in |
| --- | --- | --- |
| SchemaStore.nvim | JSON / YAML schemas for jsonls and yamlls | `plugins/lsp.lua` |
| lazy.nvim | Plugin manager (quiet update checker on; personal lockfile) | `config/lazy.lua`, `util/lockfile.lua` |
| nvim-lspconfig | LSP server definitions | `plugins/lsp.lua` |
| mason.nvim | Installs LSPs and tools | `plugins/lsp.lua` |
| mason-lspconfig | Installs servers, enables those in the language table | `plugins/lsp.lua` |
| mason-tool-installer | Auto-installs formatters/tools | `plugins/lsp.lua` |
| Trouble | Diagnostics/references panel | `plugins/lsp.lua` |
| nvim-cmp (+ cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-cmdline, cmp_luasnip) | Completion popup | `plugins/completion.lua` |
| LuaSnip + friendly-snippets | Snippets | `plugins/completion.lua` |
| nvim-treesitter (`master` branch) | Syntax parsing, highlighting, indent | `plugins/treesitter.lua` |
| Telescope + plenary + fzf-native | Fuzzy finding, live grep (fzf-native is loaded as an extension) | `plugins/telescope.lua` |
| Conform | Formatting, format on save | `plugins/formatting.lua` |
| Gitsigns | Git gutter and hunks | `plugins/git.lua` |
| mini.ai | Extra text objects | `plugins/textobjects.lua` |
| mini.pairs | Auto-close brackets and quotes | `plugins/textobjects.lua` |
| which-key | Keybinding discovery | `plugins/textobjects.lua` |
| nvim-tree | File explorer | `plugins/ui.lua` |
| lualine | Statusline and buffer tabline | `plugins/ui.lua` |
| TokyoNight (night) | Theme | `plugins/ui.lua` |
| nvim-web-devicons | Icons | `plugins/ui.lua` |
| toggleterm.nvim | Integrated terminal | `plugins/terminal.lua` |

### Extras (off by default, `vim.g.loki_extras`, see [EXTRAS.md](EXTRAS.md))

| Extra | Components | Configured in |
| --- | --- | --- |
| sessions | persistence.nvim | `extras/sessions.lua` |
| dashboard | alpha-nvim | `extras/dashboard.lua` |
| docker | toggleterm + lazydocker (no new plugin) | `util/extras.lua` |
| database | vim-dadbod, vim-dadbod-ui, vim-dadbod-completion | `extras/database.lua` |
| rest | built-in curl runner (no plugin) | `util/rest.lua` |
| dap | nvim-dap, nvim-dap-ui, nvim-nio; adapters via mason-tool-installer | `extras/dap.lua` |
| lint | nvim-lint (linters from the language table) | `extras/lint.lua` |
| surround | mini.surround (`gs` prefix) | `extras/surround.lua` |
| diffview | diffview.nvim | `extras/diffview.lua` |
| replace | grug-far.nvim | `extras/replace.lua` |
| outline | aerial.nvim | `extras/outline.lua` |
| tasks | overseer.nvim | `extras/tasks.lua` |
| test | neotest, neotest-python, neotest-jest, neotest-vitest, neotest-golang, neotest-rust, neotest-gtest | `extras/test.lua` |
| ui | indent-blankline.nvim, nvim-treesitter-context | `extras/ui.lua` |
| history | undotree | `extras/history.lua` |
| git-ui | toggleterm + lazygit (no new plugin) | `util/extras.lua` |
| github | octo.nvim | `extras/github.lua` |
| preview | markdown-preview.nvim, image.nvim | `extras/preview.lua` |
| java | nvim-jdtls (jdtls via Mason) | `extras/java.lua` |
| ai | toggleterm + your assistant CLI (no new plugin) | `util/extras.lua` |


Non-plugin code: `util/registry.lua` (every key, command and help topic: the single source of truth), `util/helpdoc.lua` (renders `:LokiHelp` and `doc/loki.txt`), `util/lsp.lua` (buffer-local LSP keys, `:LokiLsp`), `util/extras.lua` (extras registry), `util/rest.lua` (REST runner), `util/check_help.lua` and `util/smoke.lua` (the checks), `config/languages.lua` (language table) with
`util/languages.lua` (derives plugin lists), `config/presets.lua` (opt-in language presets), `util/cheatsheet.lua`
(generator, started from `init.lua`), `config/leader_groups.lua` (namespace
labels), `util/user.lua` (loads your `lua/user/` files), `util/welcome.lua`
(first-run install window, `:LokiInfo`), `util/lockfile.lua` (personal plugin
lockfile, `:LokiLockReset`), `loki/health.lua` (`:checkhealth loki`).
`util/keyguard.lua` (reports shipped keys your keymaps replace, `:LokiKeys`),
`util/guide.lua` (`:LokiHelp [topic]`, `:LokiTutor`, `:LokiEdit`, `:LokiBackup`, `:LokiDocs`).

Scripts (`scripts/`): `install.sh`, `uninstall.sh`, `update.sh`,
`user-layer.sh`, `generate-cheatsheet.sh`, `smoke-test.sh`, `check-help.sh`,
`gen-help.sh`, `install-watcher.sh`. `systemd/` holds optional
cheatsheet watcher units (ENVIRONMENT_GUIDE.md, section 7). See [INSTALL.md](INSTALL.md).

## Language support

The source of truth is `lua/config/languages.lua` (defaults) plus your own
`lua/config/languages_local.lua`; this table is a snapshot of the defaults. To add a language see [ADDING_LANGUAGES.md](ADDING_LANGUAGES.md).

| Language | LSP | Formatter | Tree-sitter |
| --- | --- | --- | --- |
| C / C++ | clangd | clang-format | c, cpp |
| Python | basedpyright | ruff (linter: ruff, `lint` extra) | python |
| Lua | lua_ls | stylua | lua, vim, vimdoc |
| Rust | rust_analyzer | rustfmt | rust |
| Bash / sh | bashls | shfmt (linter: shellcheck, `lint` extra) | bash |
| JS / TS / React | ts_ls | prettier | javascript, typescript, tsx |
| JSON / YAML | jsonls / yamlls (schemas from SchemaStore) | prettier | json, yaml |
| HTML / CSS | html / cssls | prettier | html, css |
| TOML | taplo | taplo | toml |
| Dockerfile | dockerls | none | dockerfile |
| Markdown | none | prettier | markdown, markdown_inline |

Anything else (Go, Java, ...) is opt-in through
`config/languages_local.lua`.

`auto_install` fetches other parsers on demand. Formatter tools install via
mason-tool-installer. Without a formatter, Conform falls back to LSP
formatting. Only servers in the language table are enabled. `lua_ls` is scoped
to files inside the Neovim config directory.

## VS Code equivalents

| VS Code | Here |
| --- | --- |
| IntelliSense | LSP + nvim-cmp |
| Parameter hints | Signature help (`<C-s>` in insert) |
| Hover docs | `K` |
| Go to definition / references | `gd` / `gr` |
| Rename / quick fix | `<leader>rn` / `<leader>ca` |
| Problems panel | Trouble (`<leader>xx`) |
| Quick open / search in files | `<leader>ff` / `<leader>fg` |
| Sidebar explorer | nvim-tree (`<leader>e`) |
| Open editors / tabs | Buffer tabline along the top (`H` / `L`) |
| Format document | `<leader>cf`, and on save |
| Source control gutter | Gitsigns |
| Snippets | LuaSnip |
| Integrated terminal | toggleterm (`<C-\>`) |
| Command palette | `<leader>fc` |
| Save | `<C-s>` |
