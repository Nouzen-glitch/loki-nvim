# Environment Guide

How to maintain this configuration. For install steps see
[INSTALL.md](INSTALL.md); for keys see [KEYBINDINGS.md](KEYBINDINGS.md); for
customizing and bringing your own config see [MIGRATING.md](MIGRATING.md).

## 1. Source vs active config

Master copy: wherever you cloned the repo (examples use `~/dotfiles/nvim/`).
Neovim loads `~/.config/nvim/` (replace mode) or `~/.config/loki/`
(alongside mode). `scripts/install.sh` makes that a symlink to the repo so
there is exactly one copy (see [INSTALL.md](INSTALL.md) for both modes):

```text
~/dotfiles/nvim  <---  ~/.config/nvim (symlink)  --->  Neovim
```

Plugin installs, cache, and state live elsewhere
(`~/.local/share|state|cache/nvim`, or `.../loki` when installed alongside).
Never edit plugin sources; updates overwrite them.

## 2. How loading works

```text
init.lua
 ├─ config.options
 ├─ user.options         (yours, optional)
 ├─ config.keymaps
 ├─ user.keymaps         (yours, optional)
 │                       (config.keymaps is followed by util.extras.keymaps(): keys of enabled extras)
 ├─ config.autocmds     (also: util.lsp.setup() = buffer-local LSP keys on LspAttach)
 ├─ config.lazy ──► lazy.nvim ──► plugins/*.lua, extras/<name>.lua for each name in
 │                  vim.g.loki_extras, then user/plugins/*.lua
 │                  (lockfile path from util.lockfile; user/plugins only
 │                   imported once it contains a .lua file)
 ├─ util.cheatsheet.setup()
 ├─ util.lockfile.setup()      :LokiLockReset
 ├─ util.welcome.setup()       first-run window, :LokiInfo
 ├─ util.guide.setup()         :LokiHelp, :LokiTutor, :LokiEdit, :LokiBackup
 ├─ util.extras.setup()        commands of enabled extras (:LokiRest)
 └─ util.keyguard.setup()      :LokiKeys, one-time "keys replaced" notice
```

`init.lua` runs `config.keymaps` and `user.keymaps` through
`util.keyguard.track_shipped()` / `track_user()`. While they load,
`vim.keymap.set` and `vim.keymap.del` are wrapped (the real call always still
runs) so shipped keys, replacements, removals and prefix clashes are recorded.
The result feeds `:LokiKeys`, `:checkhealth loki`, the cheatsheet and a
one-time startup notice (state file `loki-keys-seen`).

## 3. Everyday workflow

1. Pick the file (table in README).
2. Edit, restart Neovim.
3. Test: `scripts/smoke-test.sh` loads every Loki module headless and prints
   the key-conflict report (use `NVIM_APPNAME=loki` for an alongside install).
   Then try the change for real. If good, `git add . && git commit -m "..."`.
   If broken, `git restore`.

Personal files under `lua/user/` and `lua/config/languages_local.lua` are
gitignored.

**Lockfile.** Each user's plugin versions live in a personal copy
(`stdpath("data")/loki-lazy-lock.json`), seeded from the repo's
`lazy-lock.json`, so users' changes never dirty the repo. As the maintainer,
set `vim.g.loki_lockfile_in_repo = true` in your own `lua/user/options.lua`;
lazy then reads and writes the repo's `lazy-lock.json`, which you commit so
new installs get reproducible versions. Note the setting only affects the
machine you set it on.

**Releasing.** Add an entry to `CHANGELOG.md` for user-visible changes; the
new lines are what `scripts/update.sh` shows users. Mention anything they must
do (for example "run `:LokiLockReset`") under "Upgrade notes".

## 4. Plugins

- **Add:** new spec in `lua/plugins/` (new file or an existing related one);
  lazy.nvim installs on next start. For yourself only, use `lua/user/plugins/`.
- **Remove:** delete the spec, then `:Lazy clean`.
- **Update:** `:Lazy update` (or `U` in `:Lazy`). With
  `vim.g.loki_lockfile_in_repo = true`, commit the lockfile afterwards.
  The background update checker is silent; open `:Lazy` to see what is pending.
- **Updating the config itself:** `scripts/update.sh` (see [INSTALL.md](INSTALL.md)).
- **Change:** edit its spec; restart while learning.

## 4b. The help system (single source of truth)

Every shipped key, command and help topic is declared **once** in
`lua/util/registry.lua`: `desc` (short, shown by which-key), `long` (2 to 4
sentences), an optional `example`, a `see` link into `docs/` and a `group`.
Everything else reads it:

| Consumer | What it takes from the registry |
| --- | --- |
| `config/keymaps.lua`, `util/extras.lua` | creates the keys (`vim.keymap.set`, so `util/keyguard.lua` still tracks them) |
| `util/lsp.lua` | entries with `lsp = "..."`: buffer-local on `LspAttach`, global notice otherwise |
| `plugins/terminal.lua` | descriptions of the terminal-mode keys |
| `util/guide.lua` | `:LokiHelp [topic]` text, command descriptions |
| `util/helpdoc.lua` | `:LokiHelp` topic pages and the generated `doc/loki.txt` |
| `util/cheatsheet.lua` | the "Quick discovery" table |

Adding a key: add an entry to the registry (with `desc`, `long`, `group`, `see`),
add it to `docs/KEYBINDINGS.md`, run `scripts/gen-help.sh` (rewrites
`doc/loki.txt`) and `scripts/check-help.sh`. The check fails when a mapping or
Loki command lacks a description, a `<leader>` prefix lacks a group label, an
entry lacks `long`, a `see` link or anchor does not resolve, a key is missing
from `KEYBINDINGS.md`, a command is missing from the table in section 6, an
extra is missing from `EXTRAS.md` / `COMPONENTS.md` / `KEYBINDINGS.md`, a docs
file is not linked from `docs/README.md`, or `doc/loki.txt` is stale. It runs
with every extra enabled and is called by `scripts/smoke-test.sh`.

`doc/tags` is generated at startup (`util/helpdoc.lua:ensure_tags`) and is
gitignored; `doc/loki.txt` is committed.

## 5. Adding a language

Add one line to `lua/config/languages_local.lua` (or `languages.lua` for a new
default) and restart. The server, parser,
formatter and formatter tools are derived from it and installed
automatically. Full guide: [ADDING_LANGUAGES.md](ADDING_LANGUAGES.md).

## 6. Useful commands

| Command | Use |
| --- | --- |
| `:Lazy` | Plugin manager |
| `:Mason` | Servers and tools |
| `:checkhealth loki` | Versions, required tools, install state, lockfile mode, your `user/` files |
| `:LokiInfo` | How this config was installed and where any backup is |
| `:LokiLockReset` | Replace your personal lockfile with the shipped one (then restart, `:Lazy restore`) |
| `:checkhealth vim.lsp` | Servers attached to current buffer |
| `:MasonToolsInstall` | Install any missing formatters/tools from the language table |
| `:ConformInfo` | Formatter status |
| `:TSUpdate` | Update parsers |
| `:checkhealth` | Diagnose everything |
| `:LokiHelp [topic]` / `:LokiTutor` | One-screen guide (or a topic: keys, lsp, git, files, languages, extras, terminal, troubleshooting) / practice tutorial |
| `:LokiDocs` | Browse `docs/` with Telescope |
| `:LokiLsp` | Language support of the current buffer, and what to do if something is missing |
| `:LokiFormat on\|off\|status` | Format on save for this session |
| `:LokiRest` | Run the HTTP request under the cursor (`rest` extra) |
| `:Cheatsheet` / `:CheatsheetUpdate` | Open / regenerate the cheatsheet |
| `:help loki` | Offline help generated from the registry (`doc/loki.txt`) |
| `:LokiEdit {options,keymaps,plugins,languages}` | Create and open a personal file |
| `:LokiKeys` | Shipped keys the user's keymaps replaced |
| `:LokiBackup [file]` | Export personal files |
| `:LokiExtras` | Opt-in extras and which are enabled |

## 7. Cheatsheet automation

The cheatsheet is generated by `util/cheatsheet.lua` from the live
environment (keymaps, user commands, versions, attached LSPs). Never edit it.
It is written to `stdpath("state")/cheatsheet.md` (for example
`~/.local/state/nvim/cheatsheet.md`), **not** into the repo: it contains
machine-specific paths and changes on every start, which would keep git dirty.

It regenerates:

- on every Neovim start, and after `:Lazy` finishes (`LazyDone`)
- when you save any `.lua` file inside the config
- on demand: `:Cheatsheet` (regenerate and open), `:CheatsheetUpdate`
- headless: `scripts/generate-cheatsheet.sh` (follows an alongside install
  automatically)
- via systemd (optional, below)

Headless runs only see keymaps of plugins that are loaded, so the
"8 loaded / 28 total" count and missing lazy-loaded keys are expected. LSP
clients are only listed if attached when it was generated.

### Optional: systemd watcher

`scripts/install-watcher.sh` installs the units with the real path of the repo
you run it from (the files in `systemd/` are templates containing `@REPO@`):

```bash
scripts/install-watcher.sh            # copy, daemon-reload, enable
scripts/install-watcher.sh --remove   # undo
```

`PathChanged` watches only the direct contents of the repo folder, not
`lua/` subfolders. Saves inside Neovim are already covered by the autocmd, so
the watcher mainly helps with edits made outside Neovim to top-level files.

## 8. Gotchas

| Topic | Detail |
| --- | --- |
| Symlinked config path | Neovim does not resolve symlinks in buffer names. `lsp.lua` and `util/cheatsheet.lua` compare paths using `fs_realpath`, so editing via `~/dotfiles/nvim/...` or `~/.config/nvim/...` behaves the same. Keep that if you edit them |
| Alongside installs | Everything uses `stdpath()`, which follows `NVIM_APPNAME`. Never hardcode `~/.config/nvim` in Lua |
| `lua_ls` scope | Attaches only to files inside the Neovim config. Widening `root_dir` means editing the shipped `plugins/lsp.lua`, so it is a maintainer change: users who do it make `scripts/update.sh` stop until they stash or commit. A `vim.lsp.config("lua_ls", ...)` in `lua/user/options.lua` is not a reliable override, because `plugins/lsp.lua` configures `lua_ls` later |
| Enabled servers | `mason-lspconfig` enables only servers in the language table, not everything installed in Mason. To use another server, add it to `languages_local.lua` |
| Formatters | Installed automatically from the `tools` field by mason-tool-installer. `rustfmt` is the exception (comes with rustup) |
| Mason toolchains | Servers and tools install via npm, pip or go, so Node.js, Python 3 and Go must be present for the languages that need them |
| Tree-sitter branch | Pinned to `master` (upstream: locked, kept for Neovim 0.11). `main` is an incompatible rewrite that needs Neovim 0.12 and the `tree-sitter` CLI. Plan: [TREESITTER_MIGRATION.md](TREESITTER_MIGRATION.md) |
| Format key | `<leader>cf`, deliberately not `<leader>f`, which is the Find prefix and would add a `timeoutlen` delay |
| Insert-mode `<C-h>` | Deliberately not mapped: many terminals send it for Backspace. Signature help is the built-in `<C-s>` |
| Which-key spec | Defined once, in `plugins/textobjects.lua`, from `config/leader_groups.lua:which_key_spec()` |
| LSP keys | Defined in the registry (`lsp = ...`); `config/keymaps.lua` creates the *notice* version globally, `util/lsp.lua` the real buffer-local one. `keyguard.user_owns()` makes the attach step skip any key the user set, so a user's `gd` is never shadowed |
| Help files | `doc/loki.txt` is generated (`scripts/gen-help.sh`); never edit it. `scripts/check-help.sh` fails when it is stale |
| Language table cache | `util/languages.lua` merges the table once per session, so a syntax error in `languages_local.lua` is reported once; restart to pick up edits |
| Directory argument | `config/autocmds.lua` opens nvim-tree for `nvim <folder>` (netrw is disabled) |
| Cheatsheet source | Started once, from `init.lua`. Do not add a second `setup()` call |
| User layer | `lua/user/*` is gitignored except the `*.example` files and `plugins/.gitkeep`. `config/lazy.lua` imports `user.plugins` only when that folder has a `.lua` file, because lazy.nvim prints an error for an imported folder with no specs |
| Lockfile | Personal copy by default (`util/lockfile.lua`). `vim.g.loki_lockfile_in_repo` must be set in `lua/user/options.lua`, which loads before lazy starts |
| Key tracking | Only `vim.keymap.set/del` calls made while `config.keymaps` / `user.keymaps` load are seen (not `nvim_set_keymap`, not later calls). Plugin keys set late are listed in `PLUGIN_KEYS` in `util/keyguard.lua` (currently toggleterm's `<C-\>`) |
| Prefix delays | The *shorter* of two overlapping keys waits `timeoutlen`; `keyguard` reports both directions |
| Terminal options | `plugins/terminal.lua` uses plain `opts`, so users rebind keys from `lua/user/plugins/`. Keep it that way |
| Terminal-mode keys | `jk`, `<Esc>` and `<C-h/j/k/l>` are set in a `FileType toggleterm` autocmd (buffer-local), not in `config/keymaps.lua`, so other terminals (lazygit, fzf, vim) get every key. `keyguard` only tracks `config.keymaps`, so it cannot see these |
| Keys-seen notice | `keyguard.setup()` writes `<state>/loki-keys-seen` only inside the `VimEnter` callback and only when a UI is attached, so headless runs (`smoke-test.sh`, the systemd watcher) do not use up the notice |
| Cmdline completion | nvim-cmp loads on `InsertEnter` and `CmdlineEnter`; its `cmp.setup.cmdline` calls live in its `config`, so dropping `CmdlineEnter` breaks `:` and `/` completion until the first Insert |
| Leader groups | `config/leader_groups.lua:all()` merges `vim.g.loki_leader_groups`; use `all()`, not `.groups`, in new code |
| Safety copies | `scripts/user-layer.sh backup` writes to `<XDG_STATE_HOME>/loki-backups`; `util/guide.lua:backup_dir()` and `loki/health.lua` assume that same path |
| Hand-cloned configs | No install record means `util/welcome.lua` shows a one-time notice (marker file `loki-manual-notice-shown`) |
| Extras | `util/extras.lua` is the registry (name, description, groups, keys, setup, health). `plugins = true` means `lua/extras/<name>.lua` exists and is imported by `config/lazy.lua` only when enabled (lazy prints an error for an import with no specs, so plugin-free extras have no file). Adding an extra: registry entry, optional spec file, a row in `docs/EXTRAS.md`, `COMPONENTS.md`, `KEYBINDINGS.md` |
| Extra keys | Defined in the registry's `keys(map)` and called from `init.lua` inside `keyguard.track_shipped`, so a user key on the same lhs is reported by `:LokiKeys`. Do not use lazy `keys = {}` in extra specs (invisible to keyguard). Groups of an extra are added by `leader_groups.all()` only while it is enabled |
| Extra: mason-tool-installer | `extras/dap.lua` extends the shipped `ensure_installed` with `opts = function(_, opts) ... end` (checked: the shipped list is kept and the adapters are appended) |
| Extra: sessions | `sessionoptions` omits `terminal`; nvim-tree is closed on `PersistenceSavePre`; `setup` is skipped when no UI is attached so headless runs never write a session |
| Extra: docker | `util/extras.lua:tui()` removes toggleterm's Terminal-mode `jk`/`<Esc>`/`<C-h/j/k/l>` buffer maps (set by the `FileType toggleterm` autocmd) in `on_open`, so the TUI receives them |
| Extra: dap | Adapters are looked up under `stdpath("data")/mason`. The `User LokiDapSetup` event lets users add configurations from `lua/user/options.lua` |
| Extra: rest | Own runner (`util/rest.lua`), because kulala.nvim now needs a downloaded binary with a license prompt and the `tree-sitter` CLI |
| Installer record | `scripts/install.sh` writes `<state>/loki-install-info`; `util/welcome.lua` and `scripts/uninstall.sh` read it. Keep the `key=value` format in sync if you change either side |

## 9. Mental model

Your configuration is source code, plugins are dependencies, lazy.nvim is the
package manager, and Neovim loads the result from `~/.config/nvim` (or
`~/.config/loki`).
