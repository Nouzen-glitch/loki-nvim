# Customizing and Migrating

How to make this config yours without editing its files, and how to bring an
existing Neovim setup along. Installing, updating and undoing are in
[INSTALL.md](INSTALL.md).

## 1. Your personal layer

Everything below is yours and is **gitignored**, so `scripts/update.sh` and
`git pull` never conflict with it. Copy the `.example` files next to them to
start.

| File | Loaded | Use it for |
| --- | --- | --- |
| `lua/user/options.lua` | Right after `config/options.lua` | Your options; the `vim.g.loki_*` switches in section 3. Your values win. |
| `lua/user/keymaps.lua` | Right after `config/keymaps.lua` | Your keymaps. If a key is already mapped, yours replaces it. Give each mapping a `desc` so it shows in `<leader>?`. |
| `lua/user/plugins/*.lua` | After the shipped plugins | Extra lazy.nvim plugin specs, and changes to shipped ones (section 4). |
| `lua/config/languages_local.lua` | With the language table | Languages: server, parser, formatter ([ADDING_LANGUAGES.md](ADDING_LANGUAGES.md)). |

A missing file is fine. A mistake **inside** one of your files is shown as an
error message naming the file and line, and the rest of the config still
loads. `lua/user/plugins/` is only used once it contains a `.lua` file.

Check what you have with `scripts/user-layer.sh list` or `:checkhealth loki`.
`:LokiEdit options|keymaps|plugins|languages` creates each file from its example
and opens it.

## 2. Bringing your old config over

1. **Find your old config.** After a *replace* install it is in the backup
   folder (`:LokiInfo` shows the path). After an *alongside* install it is
   simply your normal `~/.config/nvim`.
2. **Options:** copy the settings you care about into `lua/user/options.lua`.
3. **Keymaps:** copy them into `lua/user/keymaps.lua`.
4. **Plugins:** if your old config used lazy.nvim, its spec files can go into
   `lua/user/plugins/` as they are. For packer or vim-plug, convert each
   plugin to a spec (section 4 shows the shape).
5. **Restart Neovim.** New plugins install on start. Then run
   `:checkhealth loki`.

Things that can surprise you:

| Topic | What happens |
| --- | --- |
| Same key, two owners | Yours wins (it loads later). Use `<leader>fk` to see what a key does first. |
| Same plugin in both places | lazy.nvim merges the two specs; `opts` tables are merged deeply. |
| Arrow keys | Disabled by default. See `vim.g.loki_disable_arrows` below. |
| Language servers | Only servers in the language table are enabled. One that is merely installed in Mason stays off until you add it to `languages_local.lua`. |
| Old plugin data | Plugins left over from another setup can load in replace mode. Use `--clean-data` or install alongside ([INSTALL.md](INSTALL.md)). |

## 3. Switches you can set

Put these in `lua/user/options.lua`. They must be set there (not later) because
they are read while the config loads.

| Setting | Default | Effect |
| --- | --- | --- |
| `vim.g.loki_disable_arrows = false` | arrows disabled | Re-enable the arrow keys in normal, insert and visual mode. |
| `vim.g.loki_leader_groups = { g = "Git" }` | none | Names for your own `<leader>` prefixes in which-key and the cheatsheet. |
| `vim.g.loki_hide_notices = true` | notices shown | Hide the one-time welcome notice for hand-cloned configs. |
| `vim.g.loki_extras = { "sessions", "dap" }` | none | Enable opt-in features. `:LokiExtras` lists them; see [EXTRAS.md](EXTRAS.md). |
| `vim.g.loki_treesitter_folding = true` | manual folds | Automatic folds from the syntax tree (`za` toggles, `zR` opens all, `zM` closes all). Needs a parser for the filetype. |
| `vim.g.loki_language_presets = { "go", "php" }` | none | Enable language presets (`go`, `php`, `csharp`, `ruby`, `zig`). See [ADDING_LANGUAGES.md](ADDING_LANGUAGES.md). |
| `vim.g.loki_ftplugin_indent = true` | 4 spaces everywhere | Let filetype plugins pick their own indent (2 for Lua, YAML, ...) instead of `shiftwidth`. A project `.editorconfig` always wins. |
| `vim.g.loki_rainbow_brackets = false` | brackets coloured by depth | Plain bracket colours. |
| `vim.g.loki_lockfile_in_repo = true` | personal lockfile | Track plugin versions in the repo's `lazy-lock.json` instead of a personal copy. For maintainers who commit it. See [INSTALL.md](INSTALL.md) section 8. |

Everything else is an ordinary Neovim option, for example
`vim.opt.shiftwidth = 2`.

### Before you override a key

If your key matches a shipped key (same mode), yours wins and the shipped one
stops working on that key. This includes the LSP keys (`K`, `gd`, `gr`, ...), which are
attached per buffer: they skip any key you set (its action is still a command: `<leader>fc`).
`:LokiKeys` and `:checkhealth loki` list every such key, and you get a
one-time notice at startup. Also:

- A key that is the start of another (yours `<leader>f`, shipped `<leader>ff`)
  makes the *shorter* key wait `timeoutlen` (400 ms).
- Plugins that set keys late win over yours (`<C-\>` from toggleterm); change
  those through the plugin's `opts` (section 4). Terminal-mode `jk`, `<Esc>` and
  `<C-h/j/k/l>` are also set late, per toggleterm buffer, so your own global
  Terminal-mode maps on those keys are shadowed there and not reported by `:LokiKeys`.
- Check first: `jk`, `<C-s>`, `<C-h/j/k/l>`, `H`, `L`, `K`, `gd`, `gr`, `<Esc>`,
  `<C-\>`, and the `<leader>f`, `<leader>w`, `<leader>c` prefixes.
- Use `vim.keymap.set`; other APIs are not checked.

## 4. Changing shipped plugins without editing them

lazy.nvim merges specs that name the same plugin, so a file in
`lua/user/plugins/` can add, tweak or disable:

```lua
-- lua/user/plugins/mine.lua
return {
    -- add a plugin
    { "ThePrimeagen/harpoon", branch = "harpoon2", dependencies = { "nvim-lua/plenary.nvim" } },

    -- change a shipped plugin's options
    { "nvim-telescope/telescope.nvim", opts = { defaults = { layout_strategy = "vertical" } } },

    -- turn a shipped plugin off
    { "folke/trouble.nvim", enabled = false },
}
```

`lua/user/plugins/example.lua.example` has the same snippets to copy from.

Example: rebind the terminal key (toggleterm sets `<C-\>` itself, after your
keymaps, so a keymap of yours cannot override it):

```lua
{ "akinsho/toggleterm.nvim", opts = { open_mapping = [[<C-t>]] } },
```

### Common tweaks (no shipped file needs editing)

Turn off format on save (`<leader>cf` still formats on demand):

```lua
-- lua/user/plugins/mine.lua
return {
    { "stevearc/conform.nvim", opts = { format_on_save = false } },
}
```

Per-server LSP settings, or a server that is not in Mason, go in
`lua/user/options.lua` (core Neovim API, works before plugins load):

```lua
vim.lsp.config("gopls", { settings = { gopls = { staticcheck = true } } })
```

## 5. Keeping your layer safe and portable

Your personal files are not in the project's git history. To back them up or
move them to another machine:

```bash
scripts/user-layer.sh export ~/loki-user.tar.gz      # on the old machine
scripts/user-layer.sh import ~/loki-user.tar.gz      # on the new one
```

`:LokiBackup` does the same export from inside Neovim (to `~/loki-user-layer-<date>.tar.gz`).
`scripts/install.sh` and `scripts/update.sh` also save a safety copy to
`~/.local/state/loki-backups/` before they change anything (newest 10 are
kept; `scripts/user-layer.sh backups` lists them). Never delete or re-clone the
repo folder without exporting first: a fresh clone does not contain `lua/user/`.

Details and safety checks are in [INSTALL.md](INSTALL.md), section 6. If you
prefer git, you can also fork the repo and remove the personal-file lines from
`.gitignore` to track them there.

## 6. Commands added by this config

| Command | Use |
| --- | --- |
| `:checkhealth loki` | Versions, required tools, install state, your personal files |
| `:LokiInfo` | How this config was installed and where any backup is |
| `:LokiLockReset` | Adopt the plugin versions shipped with the config |
| `:Cheatsheet` / `:CheatsheetUpdate` | Open / regenerate the live cheatsheet |
| `:LokiHelp` (`<leader>fi`) | One-screen guide: what you can do and should do |
| `:LokiTutor` | Short practice tutorial |
| `:LokiEdit {options,keymaps,plugins,languages}` | Create (from the example) and open a personal file |
| `:LokiKeys` | Shipped keys your keymaps replaced, removed or delayed |
| `:LokiBackup [file]` | Export your personal files (they are not in git) |
| `:LokiExtras` | List opt-in extras and which are enabled |
| `:LokiFormat on\|off\|status` | Turn format on save on or off for this session (`<leader>cf` always formats) |
| `:LokiRest` | Run the HTTP request under the cursor (`rest` extra only) |
| `:LokiHelp [topic]` | Also takes a topic: keys, lsp, git, files, languages, extras, terminal, troubleshooting (also `:help loki`) |
| `:LokiDocs` | Browse `docs/` |
| `:LokiLsp` | Language support of this buffer |
