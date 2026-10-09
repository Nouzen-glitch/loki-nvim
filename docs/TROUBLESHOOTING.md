# Troubleshooting

Start with `:checkhealth loki`. It checks versions, required tools, install
state, your personal files, key conflicts, safety copies, the language table and
enabled extras. For one buffer, `:LokiLsp` explains language support.

## First checks

| Command | Tells you |
| --- | --- |
| `:checkhealth loki` | Everything this config needs |
| `:LokiLsp` | Why LSP, formatting or highlighting does or does not work here |
| `:LokiKeys` | Shipped keys your keymaps replaced or delayed |
| `:Lazy` | Plugin install and error state (`I` retries, `U` updates) |
| `:Mason`, `:MasonLog` | Servers and tools, install errors |
| `:checkhealth vim.lsp` | Attached servers and their capabilities |
| `:checkhealth which-key` | Why the key popup is missing |
| `:messages` | Recent errors |

## Install and update

| Symptom | Cause and fix |
| --- | --- |
| `nvim-loki: command not found` | `~/.local/bin` is not on `PATH`: add `export PATH="$HOME/.local/bin:$PATH"`, or run `NVIM_APPNAME=loki nvim` |
| Installer says the launcher "exists and was not created by this installer" | Something else is at that path. Use `NVIM_APPNAME=<name> nvim`, or move the file and re-run |
| Neovim starts empty after moving the repo | The link is broken. Run `scripts/install.sh` from the new location; `uninstall.sh` cannot see a broken link (`rm ~/.config/nvim`) |
| Plugins from my old setup load | They live in `~/.local/share/nvim`. Reinstall with `--replace --clean-data` or use `--alongside` |
| Plugins fail to install | Needs `git` and a network. `:Lazy`, press `I` |
| Tree-sitter or fzf-native fails to build | Install a C compiler and `make` |
| `update.sh` refuses | You edited a shipped file: `git stash` or commit. Personal changes belong in `lua/user/` |
| `git pull` complains about `lazy-lock.json` | `vim.g.loki_lockfile_in_repo = true` is set and the file changed: commit it or `git checkout lazy-lock.json` |
| My `lua/user/` files vanished after a re-clone | They are not in git. `scripts/user-layer.sh backups`, then `import` the newest |
| Came from "Elite Neovim" (the old name) | See the 2026-10-04 entry in [../CHANGELOG.md](../CHANGELOG.md) |

## Keys

| Symptom | Cause and fix |
| --- | --- |
| No key popup | `:checkhealth which-key`; some terminals swallow keys |
| A key does something else | `<leader>fk` shows what it maps to; `:LokiKeys` lists replaced keys |
| Startup notice "your keymaps replace N shipped keys" | `:LokiKeys`; pick other keys or delete your lines |
| A key waits before acting | It is the start of a longer key. `gr` waits 400 ms because `grr`, `gra`, `grn` exist; see [KEYBINDINGS.md](KEYBINDINGS.md) |
| `<C-\>` does not toggle the terminal | The terminal or another program took it. Rebind via toggleterm `opts` |
| Backspace switches windows | Your terminal sends `<C-h>` for Backspace; remap Backspace in the terminal or pick other window keys in `lua/user/keymaps.lua` |
| Arrow keys do nothing | By design; `vim.g.loki_disable_arrows = false` |
| `jk` types j and k | Type them quickly, or use `<Esc>` |
| Indent is 2 in some files | A project `.editorconfig`, or `vim.g.loki_ftplugin_indent = true`, sets it. Format on save uses your `shiftwidth` only when the project has no formatter config; a `.clang-format`, `.prettierrc`, `.editorconfig` or `stylua.toml` wins, so set the indent there |
| Clipboard does not work | Install `wl-clipboard` (Wayland) or `xclip` (X11); `:checkhealth loki` |

## Language support

| Symptom | Cause and fix |
| --- | --- |
| LSP key prints "needs a language server" | None attached; `:LokiLsp` |
| Server missing in `:Mason` | Wrong lspconfig name in `lsp`, or Node.js / Python 3 / Go missing; `:MasonLog` |
| Installed but not attached | Not in the language table, wrong filetype key (`:set ft?`), or file outside a project root |
| `<leader>cf` does nothing | Formatter not installed (`:ConformInfo`) or wrong Conform name |
| No colours | Wrong parser name (`:TSInstallInfo`); `:checkhealth nvim-treesitter` |
| Highlighting but no IntelliSense | Only a parser is listed; add `lsp` |
| `languages_local.lua error` at startup | Syntax error: check commas and braces |
| Lua files get no LSP | `lua_ls` is scoped to this config folder on purpose |
| Linter does nothing | The `lint` extra is not enabled, or the linter is not installed (`:checkhealth loki`) |

## Finding and files

| Symptom | Cause and fix |
| --- | --- |
| `<leader>fg` does nothing | Install `ripgrep` (`rg`) |
| Icons are boxes | Use a Nerd Font in the terminal |
| `nvim .` shows an empty buffer | The explorer opens for exactly one folder argument |

## Extras

| Symptom | Cause and fix |
| --- | --- |
| "unknown extra(s)" warning | Name not in `:LokiExtras` |
| Extra key does nothing | The extra is not enabled in `vim.g.loki_extras` (restart afterwards) |
| `docker` / `database` / `dap` missing tools | `:checkhealth loki` lists them |

## Help system

| Symptom | Cause and fix |
| --- | --- |
| `:help loki` not found | `doc/tags` is generated at startup; restart, or `:helptags ALL`. If `doc/loki.txt` is missing run `scripts/gen-help.sh` |
| `scripts/check-help.sh` fails | It names the missing description, doc row or stale file. Regenerate `doc/loki.txt` with `scripts/gen-help.sh` |
