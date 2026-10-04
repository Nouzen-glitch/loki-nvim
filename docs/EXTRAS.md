# Extras (opt-in features)

Heavier features ship as **extras**: off by default, so the config behaves
exactly as before until you ask for more. A disabled extra loads nothing and
defines no keys.

Enable them in `lua/user/options.lua` (`:LokiEdit options`), then restart:

```lua
vim.g.loki_extras = { "sessions", "dashboard", "dap" }
```

`:LokiExtras` lists every extra and shows which are enabled. An unknown name
gives a warning, not an error. Plugins of an enabled extra install on the next
start (watch `:Lazy`). Run `:checkhealth loki` to see which external tools an
enabled extra is missing (always a warning, never an error).

| Extra | What it gives you | Needs | Keys |
| --- | --- | --- | --- |
| `sessions` | Restore the files and splits of a folder | nothing | `<leader>ss` `sl` `sd` |
| `dashboard` | Start screen for a bare `nvim` | nothing | shortcut letters on the screen |
| `docker` | lazydocker in a floating terminal | `docker`, `lazydocker` | `<leader>kk` |
| `database` | Database UI and SQL completion | the DB's CLI client (`psql`, `mysql`, `sqlite3`) | `<leader>kd` |
| `rest` | Run `.http` requests | `curl` | `<leader>kr`, `:LokiRest` |
| `dap` | Debugging with a variables UI | Python 3 (debugpy), Node.js (JS); Mason installs the adapters | `<leader>t…`, F-keys |
| `lint` | Linting on save (nvim-lint) | the linter programs (`ruff`, `shellcheck` by default; Mason installs them) | `<leader>cl` |
| `surround` | Add / delete / replace surrounding quotes and brackets (mini.surround) | nothing | `gsa` `gsd` `gsr` |

Prefixes added by extras (declared only while the extra is enabled): `s`
Session, `k` Clients, `t` Debug. `surround` uses the `gs` prefix.

## sessions

Uses `folke/persistence.nvim`. The session of the current folder (and git
branch) is saved when you quit. It is **never** restored automatically:

| Key | Action |
| --- | --- |
| `<leader>ss` | Restore the session of this folder |
| `<leader>sl` | Restore the last session |
| `<leader>sd` | Do not save this session |

Saved in `stdpath("state")/sessions/`. Terminal and nvim-tree windows are left
out (they do not restore well). Nothing is saved from headless runs. Starting
with `nvim somefile` is unaffected.

## dashboard

Uses `goolord/alpha-nvim`. Shown only for a bare `nvim` (not for `nvim file`,
`nvim .`, stdin or headless runs). Buttons: find file, recent files, restore
session (only when `sessions` is enabled), guide, tutorial, plugins, quit. The
dashboard buffer is not listed, so `H` / `L` and the buffer tabline ignore it.
The first-run install window still appears on top of it.

## docker

No plugin: toggleterm runs `lazydocker` in a hidden floating terminal. If the
program is missing you get a message instead of an empty terminal. `jk`,
`<Esc>` and `<C-h/j/k/l>` go to lazydocker. `<C-\>` and `:TermSelect` are not
affected. Install `docker` and `lazydocker` yourself.

## database

Uses `vim-dadbod`, `vim-dadbod-ui` and `vim-dadbod-completion` (SQL buffers
only; the shipped completion sources are untouched). `<leader>kd` toggles the UI.
Needs a Nerd Font and the command-line client of each database.

**Secrets.** Connection strings contain passwords. Keep them in environment
variables, for example `export DBUI_URL=postgres://user:pass@host/db`, or add
them in the UI (saved to `stdpath("data")/db_ui/`, outside the repo). Do not put
them in files under `lua/user/`: `scripts/user-layer.sh export` and the
safety copies pack that folder, so a secret there ends up in every archive.

## rest

A small built-in runner, no plugin. `kulala.nvim` was evaluated and is not
used: it now downloads a separate `kulala-core` binary (with a license prompt)
and needs the `tree-sitter` CLI, which does not fit this config. The runner
sends the request block under the cursor with `curl` and shows the response in
a split (`q` closes it).

```http
### list
GET https://example.com/api/items
Authorization: Bearer {{API_TOKEN}}

### create
POST https://example.com/api/items
Content-Type: application/json

{"name": "x"}
```

Blocks are separated by `###`. `{{NAME}}` is replaced by the environment
variable `NAME`; an unset variable stops the request with a message. Before a request that
uses variables is sent, you are asked to confirm the host that will receive them. Keep
tokens in the environment, never in the file. Not supported: scripting, request
chaining, `.env` files. Prefer a full client? Add one from `lua/user/plugins/`.

## dap

Uses `nvim-dap`, `nvim-dap-ui` and `nvim-nio`. Mason installs the adapters
`debugpy`, `codelldb` and `js-debug-adapter`. Adapters and a "launch" setup are
built in for Python, C, C++, Rust, JavaScript and TypeScript. The UI opens when
a session starts and closes when it ends.

| Key | Action |
| --- | --- |
| `<leader>tb` / `<F9>` | Toggle breakpoint |
| `<leader>tc` / `<F5>` | Start / continue |
| `<F10>` `<F11>` `<S-F11>` | Step over / into / out |
| `<leader>tu` | Toggle the debug UI |
| `<leader>tx` | Stop |

Some terminals intercept F-keys (and `<S-F11>`); the `<leader>t` keys always work.
`<leader>d…` (diagnostics) is unchanged.

**Add or change an adapter** without editing shipped files, in
`lua/user/options.lua`:

```lua
vim.api.nvim_create_autocmd("User", {
    pattern = "LokiDapSetup",
    callback = function()
        local dap = require("dap")
        dap.configurations.python = {
            { type = "python", request = "launch", name = "With args", program = "${file}", args = { "--debug" } },
        }
    end,
})
```

Install extra adapters through `lua/config/languages_local.lua`'s `tools` field
or `:Mason`. Notes: `debugpy` is installed into a venv (needs Python 3 with
`venv`); `codelldb` expects a binary built with debug info (`gcc -g`).

## lint

Uses `mfussenegger/nvim-lint`. Linters come from the `linter` field of the
language table ([ADDING_LANGUAGES.md](ADDING_LANGUAGES.md)); by default Python
uses `ruff` and shell files use `shellcheck`. Linting runs when a file is opened,
on save and on leaving Insert mode, and the results appear as normal diagnostics
(`]d`, `<leader>xx`). A linter whose program is not installed is skipped
silently; `:checkhealth loki` lists the missing ones.

| Key | Action |
| --- | --- |
| `<leader>cl` | Lint this buffer now |

Add a linter in `lua/config/languages_local.lua`, for example
`javascript = { lsp = "ts_ls", parser = "javascript", linter = "eslint_d", tools = { "eslint_d" } },`
(linter names are nvim-lint names, `tools` are Mason package names).
Common failure: nothing happens, because the program is not on `PATH`
(`:Mason`, then restart).

## surround

Uses `echasnovski/mini.surround` with the `gs` prefix (the default `s` prefix would
make the plain `s` key wait). Keys that wrap or unwrap text:

| Key | Action | Example |
| --- | --- | --- |
| `gsa` + motion + character | Add surrounding | `gsaiw)` puts parentheses around the word |
| `gsa` (Visual) + character | Surround the selection | select, `gsa"` |
| `gsd` + character | Delete surrounding | `gsd"` removes the quotes around the cursor |
| `gsr` + old + new | Replace surrounding | `gsr"'` turns `"` into `'` |

`gsf`, `gsF`, `gsh` and `gsn` find, highlight and change the search range
(`:help MiniSurround`). Common failure: a delay after `gs` is the popup waiting
for the next key.

## Persistent terminals (detach / reattach)

Not implemented as a feature. The dependable way is to run Neovim itself inside
`tmux` or `zellij`: detach with the multiplexer, and the editor, its terminals
and their running commands survive. Inside Neovim, `<C-\>` and `2<C-\>` keep
working as usual. Wrapping each toggleterm shell in `dtach` or `abduco` is
possible but needs per-terminal sockets, so it was left out until it can be
tested.

## Not shipped (needs a decision)

- **AI assistant**: depends on the vendor you pick (`claudecode.nvim`,
  `codecompanion.nvim`, Copilot, ...). Keys would come from environment variables only.
- **Tree-sitter text objects for function definitions** (`af`/`if`): needs `nvim-treesitter-textobjects`; see [TREESITTER_MIGRATION.md](TREESITTER_MIGRATION.md) for the branch plan first.
- **Windows installer**: the supported route is WSL ([INSTALL.md](INSTALL.md)).
