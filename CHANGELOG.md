# Changelog

Newest first. `scripts/update.sh` prints the new entries when you update.

## Unreleased

### Added

- **Five opt-in extras:** `git-ui` (lazygit: `<leader>gg`), `github` (octo.nvim: `<leader>Gp` `Gi` `Gr`), `preview` (Markdown in the browser `<leader>pm`; terminal images on kitty-graphics terminals), `java` (jdtls through nvim-jdtls), `ai` (an assistant CLI in a side terminal: `<leader>aa`, set `vim.g.loki_ai_cmd`).
- `dap`: launch.json types `debugpy`, `node`, `go` and `cppdbg` now map to a working adapter (`cppdbg` runs through codelldb, best effort).
- `test`: Go, Rust (cargo-nextest), C/C++ (GoogleTest) and Vitest adapters, each loaded safely; `<leader>nl` (run last), `<leader>nd` (debug nearest, with `dap`); adapters can be added with `User LokiNeotestAdapters`.
- `tasks`: tasks.json output goes to quickfix and diagnostics; `<leader>ml` (run last task), `<leader>mq` (quickfix list).
- Language presets: `vim.g.loki_language_presets = { "go", "php", "csharp", "ruby", "zig" }`.
- Docs: `AI.md`, `REMOTE.md`.

### Changed

- `util.extras.tui` takes options (direction, size) and accepts commands with arguments.
- `test`: the extra's description and the `<leader>nn` help text now name all supported adapters.

### Upgrade notes

- Run `:LokiLockReset`, restart, then `:Lazy restore` to adopt the lockfile entries for the new plugins (installed only for the extras you enable).
- With `dap` enabled, Mason installs `delve` (needs Go). With `java` enabled, Mason installs `jdtls` (needs a JDK).
- External tools by extra: `lazygit` (git-ui), `gh` + `gh auth login` (github), ImageMagick (terminal images), `cargo-nextest` (Rust tests).

## 2026-10-05

Closes the gaps with VS Code that mattered most for daily programming. The full
analysis, including what is still missing on purpose, is in
[docs/VSCODE_GAP.md](docs/VSCODE_GAP.md).

### Added

- **Seven new opt-in extras** (off by default, enable in `vim.g.loki_extras`): `diffview` (diff of all changes, file history, 3-way merge: `<leader>gd` `gh` `gq`), `replace` (project-wide search and replace: `<leader>R`), `outline` (symbol sidebar: `<leader>o`), `tasks` (make / npm / cargo / `tasks.json`: `<leader>mr` `mt`), `test` (test explorer for pytest and jest: `<leader>nn` `nf` `ns` `no` `nx`), `ui` (indent guides and sticky scroll), `history` (undo tree: `<leader>u`).
- JSON and YAML now have language servers (`jsonls`, `yamlls`) with schema validation from SchemaStore (`package.json`, `tsconfig.json`, GitHub workflows, docker-compose, ...). HTML, CSS, TOML and Dockerfile are default languages too.
- Keys: `<leader>ci` / `<leader>co` (call hierarchy), `<leader>fR` (resume the last picker), `<leader>fw` (search the word under the cursor), `<leader>f/` (fuzzy search lines in this file).
- `.github/workflows/ci.yml` runs `scripts/check-help.sh` and `scripts/smoke-test.sh` on Neovim 0.11 and stable.

### Upgrade notes

- Run `:LokiLockReset`, restart, then `:Lazy restore` to adopt the lockfile entries for the new plugins (`SchemaStore.nvim` is installed for everyone; the extras' plugins only when enabled).
- Mason installs `json-lsp`, `yaml-language-server`, `html-lsp`, `css-lsp`, `taplo` and `dockerfile-language-server` on the next start (needs Node.js). To keep the old behaviour for a language, put `json = { parser = "json", formatter = "prettier", tools = { "prettier" } },` (or `html = false`, `css = false`, ...) in `lua/config/languages_local.lua`.

## 2026-10-04

### Changed (rename)

- **Elite Neovim is now Loki Neovim** (repository `loki-nvim`). Commands `:Elite*` are now `:Loki*`, `vim.g.elite_*` is now `vim.g.loki_*`, `:checkhealth elite` is `:checkhealth loki`, the alongside app name is `loki` (launcher `nvim-loki`, folders `~/.config/loki` etc.), `lua/elite/` is `lua/loki/`, and the state files are `loki-*`. Entries below this one keep the old names as history.

### Added

- **One source of truth**: `lua/util/registry.lua` declares every shipped key, command and help topic (short `desc`, `long` text, example, doc link). Keys, which-key labels, `:LokiHelp`, `doc/loki.txt` and the cheatsheet table are all produced from it.
- `scripts/check-help.sh` fails when a mapping or command lacks a description, a `<leader>` prefix lacks a group label, a registry entry lacks `long` or a resolvable doc link, a key is missing from `docs/KEYBINDINGS.md`, a command is missing from the Environment Guide, an extra is undocumented, or `doc/loki.txt` is stale. `scripts/smoke-test.sh` runs it.
- `scripts/gen-help.sh` regenerates `doc/loki.txt`; `:help loki` (tags `loki-keys`, `loki-lsp`, `loki-git`, `loki-files`, `loki-languages`, `loki-extras`, `loki-terminal`, `loki-troubleshooting`, `loki-commands`).
- `:LokiHelp [topic]` with completion (keys, lsp, git, files, languages, extras, terminal, troubleshooting); `:LokiDocs` (Telescope over `docs/`); `:LokiLsp` (attached servers, root, formatter, parser, and what to do when one is missing). Help windows have headings and highlighting.
- LSP keys (`K gd gD gi gr <leader>rn <leader>ca <leader>D <leader>ds <leader>ih`) are buffer-local on `LspAttach`. In buffers without a server they print a notice that points at `:LokiLsp`. A key you set yourself is never shadowed.
- which-key: labels for `]`/`[`, mini.ai objects after `d`/`c`/`y` then `i`/`a`, Neovim's `gr*`/`gO` defaults; clearer group names.
- Keys: `<leader>fs` `fS` (symbols), `fd` (diagnostics), `fG` (git status), `<leader>hb` `hB` `hd` `hu` (blame, line blame, diff, undo stage); `<leader>hs`/`hr` work on a Visual selection.
- Extras `lint` (nvim-lint, `linter` field in the language table; `<leader>cl`) and `surround` (mini.surround: `gsa` `gsd` `gsr`). Opt-in tree-sitter folding: `vim.g.loki_treesitter_folding = true`.
- Docs: `LSP.md`, `COMPLETION.md`, `FINDING.md`, `FILES.md`, `GIT.md`, `TERMINAL.md`, `PLUGIN_KEYS.md`, `CONCEPTS.md`, `TROUBLESHOOTING.md`, `TREESITTER_MIGRATION.md` (a plan only).
- `scripts/install-watcher.sh`; the `systemd/` files are templates, so nothing is hardcoded to `~/dotfiles/nvim`.

### Fixed

- `scripts/smoke-test.sh` could never fail (`+lua assert` exits 0). It now exits non-zero on any failure.
- `nvim <folder>` showed an empty buffer; it now opens the file explorer.
- `lua_ls` root check also matched sibling folders such as `nvim-old`.
- A syntax error in `languages_local.lua` produced one error toast per caller; the table is now merged once.
- nvim-cmp capabilities are passed to every language server.
- `uninstall.sh` also finds installs made under the old `elite` name.
- Docs: stale tree-sitter comment, clone URL, command tables, `j`/`k` count behaviour.
- Visual `p` pasted one character too early when the selection ended at the end of a line; it now uses Visual `P`.
- `:LokiHelp` and `:help loki` no longer collapse the indentation of code examples (`go = { ... }`, `vim.g.loki_extras = ...`).
- `scripts/user-layer.sh` import refuses archives that contain links or special files.
- The `lint` extra no longer calls a private nvim-lint function; the first-run window uses extmarks instead of the deprecated `nvim_buf_add_highlight`.

### Upgrade notes

- **Renamed install (alongside, app name `elite`)**: run `scripts/install.sh --alongside` (creates `loki`), then `scripts/uninstall.sh --appname elite`. Plugins reinstall under the new app name. Your `lua/user/` files stay in the repo folder; rename any `vim.g.elite_*` setting in them to `vim.g.loki_*`, and any `:Elite*` mapping to `:Loki*`.
- **Replace install (`nvim`)**: nothing moves; just rename `vim.g.elite_*` to `vim.g.loki_*` in `lua/user/options.lua`. Old safety copies stay in `~/.local/state/elite-backups/`; new ones go to `loki-backups`.
- Run `:LokiLockReset`, restart, then `:Lazy restore` to adopt the lockfile entries for `nvim-lint` and `mini.surround`.
- `shellcheck` is now installed by Mason for shell files (used only when the `lint` extra is on).
- `doc/tags` is generated on start; `:help loki` works after the first launch.

## 2026-10-03

### Added

- `:EliteFormat on|off|status` turns format on save on or off for the session.
- `<leader>E` reveals the current file in the explorer.
- Clearer key descriptions (they now say what happens), a which-key section in `docs/KEYBINDINGS.md` and in `:EliteHelp`.
- `:checkhealth elite` checks for a clipboard provider and validates the language table.

### Fixed

- `j`/`k` keep working with counts (`5j` moves 5 real lines).
- `prettier` (and `shfmt` for `bash`) are installed even if the language that used to own them is disabled.
- Terminal-mode keys have descriptions; cursor restore skips help, rebase and other special buffers.
- `:EliteEdit` completion filters what you typed; a bad language-table value no longer crashes startup.
- Cheatsheet: no `<Plug>` maps, atomic writes, generated just after startup.
- `rest` extra asks for confirmation before sending environment variables.
- Extras install the parsers they need (`sql`, `http`, `dockerfile`).
- Docs: README layout lists `EXTRAS.md`, clipboard tool added to requirements, fold comment corrected.

### Upgrade notes

- Nothing is required. Restart Neovim. Install `wl-clipboard` or `xclip` if `:checkhealth elite` reports no clipboard provider.

## 2026-10-01

### Added

- **Extras**: opt-in features, all off by default. Enable in `lua/user/options.lua`, for example `vim.g.elite_extras = { "sessions", "dashboard" }`. `:EliteExtras` lists them; unknown names only warn. New `docs/EXTRAS.md`.
  - `sessions` (persistence.nvim): `<leader>ss` restore this folder, `<leader>sl` last session, `<leader>sd` do not save. Never restores by itself.
  - `dashboard` (alpha-nvim): start screen for a bare `nvim` only.
  - `docker`: `<leader>kk` opens lazydocker in a floating terminal (no plugin).
  - `database` (vim-dadbod, vim-dadbod-ui): `<leader>kd`, SQL completion in SQL buffers.
  - `rest`: `<leader>kr` / `:EliteRest` runs the `.http` request under the cursor with curl (built in; kulala.nvim now needs a downloaded binary and the tree-sitter CLI).
  - `dap` (nvim-dap, nvim-dap-ui): `<leader>tb` `tc` `tu` `tx`, `<F5>` `<F9>` `<F10>` `<F11>` `<S-F11>`; Mason installs debugpy, codelldb and js-debug-adapter. Extra adapters via `User EliteDapSetup`.
- `:checkhealth elite` has an extras section (missing tools are warnings).
- WSL 2 is documented as the way to use this config on Windows.

### Fixed

- `lazy-lock.json` now lists `mini.pairs` and the extras' plugins.

### Upgrade notes

- Nothing is required: with `vim.g.elite_extras` unset nothing changes.
- To use an extra, add it to `vim.g.elite_extras` in `lua/user/options.lua` and restart; new plugins install automatically. Run `:checkhealth elite` for missing tools.
- If you commit `lazy-lock.json` yourself (`vim.g.elite_lockfile_in_repo = true`), run `:Lazy` once with the extras you want and commit it.

## 2026-09-30

### Added

- `:EliteHelp` (`<leader>fi`) one-screen guide, `:EliteTutor` practice tutorial, `:EliteEdit options|keymaps|plugins|languages` (creates each personal file from its example and opens it), `:EliteBackup`. New `docs/GETTING_STARTED.md`.
- `:EliteKeys` and `:checkhealth elite` list shipped keys your keymaps replace, remove or delay (prefix clashes); a one-time notice appears at startup when that list changes.
- Safety copies: `install.sh` and `update.sh` save your personal files to `~/.local/state/elite-backups/` first (newest 10 kept). New `scripts/user-layer.sh backup` / `backups`.
- `vim.g.elite_leader_groups` names your own `<leader>` prefixes in which-key and the cheatsheet.
- One-time welcome notice when the config was cloned by hand instead of installed with `scripts/install.sh`; `:checkhealth elite` also reports install state and backups.
- `scripts/install.sh` rewritten: install **alongside** (`nvim-elite`, nothing of yours is touched) or **replace** (`nvim`, old config backed up), plus `--dry-run`, `--clean-data`, `--yes`, `--appname`. Ends with a summary of what happened and how to undo it.
- `scripts/uninstall.sh` (removes the link/launcher, restores your backup), `scripts/update.sh` (shows incoming changes, refuses to overwrite local edits), `scripts/user-layer.sh` (export/import your personal files between machines).
- First launch after install shows a window with the backup location and undo command; `:EliteInfo` shows it again.
- `:checkhealth elite` checks versions, required tools and your personal files.
- Personal layer in `lua/user/` (options, keymaps, plugins), gitignored so updates never conflict. See `docs/MIGRATING.md`.
- `mini.pairs` (auto-close brackets and quotes) and a buffer tabline (via lualine).
- Small comforts: `<Esc>` clears search highlight, `<C-s>` saves, `<leader>q` quits, centered `<C-d>`/`<C-u>`, `J`/`K` move selected lines, visual `p` keeps your register, cursor position restored on reopen, files reload when changed on disk, missing folders created on save, `confirm`/`inccommand`/`winborder`.
- New docs: `docs/INSTALL.md` (every flag, scenario walkthroughs, troubleshooting).

### Changed

- The cheatsheet now lists insert, terminal, command-line, select and operator-pending keys and buffer-local keys, and shows your leader groups and replaced keys.
- toggleterm options are plain `opts`, so they can be changed from `lua/user/plugins/` (for example to rebind `<C-\>`).
- The plugin lockfile is now a personal copy in Neovim's data folder, seeded from `lazy-lock.json`. Adding plugins no longer modifies a tracked file. Maintainers who want to commit it set `vim.g.elite_lockfile_in_repo = true` in `lua/user/options.lua`. `:EliteLockReset` adopts the shipped versions.
- The generated cheatsheet now lives in Neovim's state folder (`:Cheatsheet` opens it), not in `docs/`.
- Only language servers listed in the language table are enabled; servers that merely exist in Mason stay off.
- Arrow keys stay disabled by default; opt out with `vim.g.elite_disable_arrows = false`.
- The update checker no longer pops up notifications; open `:Lazy` to see pending updates.

### Fixed

- `telescope-fzf-native` was built but never loaded.
- Insert-mode `<C-h>` (signature help) removed: many terminals send it for Backspace. Use the built-in `<C-s>`.
- Deprecated APIs replaced (`vim.hl.on_yank`, `vim.uv`, conform `lsp_format`).
- The installer no longer reports Neovim's own freshly created state folder as "old data".
- lazy.nvim no longer prints an error when `lua/user/plugins/` is empty.

### Fixed (follow-up)

- `scripts/user-layer.sh`: relative paths (`export mine.tgz`, `import mine.tgz`, and the default archive name) now resolve from the folder you ran it in, not the repo. This also fixes `:EliteBackup name.tgz`.
- `:` and `/` completion works before you first enter Insert mode (nvim-cmp now also loads on `CmdlineEnter`).
- The "keys replaced" startup notice is no longer marked as seen by headless runs (smoke test, cheatsheet watcher).
- Terminal keys (`jk`, `<Esc>`, `<C-h/j/k/l>`) apply only to the toggleterm terminal, so TUIs such as lazygit or fzf keep them.
- `--help` in `update.sh`, `uninstall.sh` and `user-layer.sh` no longer prints the `set -euo pipefail` line; `uninstall.sh --dry-run` no longer claims it restored or removed anything; `smoke-test.sh` detects an alongside install.
- Docs: terminal-mode key caveats, `lua_ls` override note and new maintainer gotchas.
- Arrow-key `<Nop>` maps have a `desc`; `<leader>e` is no longer also declared as a which-key group.

### Upgrade notes

- Nothing is required. Run `:EliteHelp` once to see what is new, and `:checkhealth elite` to see your safety copies and key conflicts.
- Delete `docs/cheatsheet.md` if you still have it (it is no longer generated there).
- Restart Neovim: `mini.pairs` installs automatically (watch `:Lazy`).
- If you commit `lazy-lock.json` yourself, add `vim.g.elite_lockfile_in_repo = true` to `lua/user/options.lua`.
