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

| Extra       | What it gives you                                                              | Needs                                                                       | Keys                           |
| ----------- | ------------------------------------------------------------------------------ | --------------------------------------------------------------------------- | ------------------------------ |
| `sessions`  | Restore the files and splits of a folder                                       | nothing                                                                     | `<leader>ss` `sl` `sd`         |
| `dashboard` | Start screen for a bare `nvim`                                                 | nothing                                                                     | shortcut letters on the screen |
| `docker`    | lazydocker in a floating terminal                                              | `docker`, `lazydocker`                                                      | `<leader>kk`                   |
| `database`  | Database UI and SQL completion                                                 | the DB's CLI client (`psql`, `mysql`, `sqlite3`)                            | `<leader>kd`                   |
| `rest`      | Run `.http` requests                                                           | `curl`                                                                      | `<leader>kr`, `:LokiRest`      |
| `dap`       | Debugging with a variables UI, reads `.vscode/launch.json`                     | Python 3 (debugpy), Node.js (JS), Go (delve); Mason installs the adapters   | `<leader>t…`, F-keys           |
| `lint`      | Linting on save (nvim-lint)                                                    | the linter programs (`ruff`, `shellcheck` by default; Mason installs them)  | `<leader>cl`                   |
| `surround`  | Add / delete / replace surrounding quotes and brackets (mini.surround)         | nothing                                                                     | `gsa` `gsd` `gsr`              |
| `diffview`  | Diff view of all changes, file history, 3-way merge (diffview.nvim)            | `git`                                                                       | `<leader>gd` `gh` `gq`         |
| `replace`   | Search and replace across the project (grug-far.nvim)                          | `ripgrep`                                                                   | `<leader>R`                    |
| `outline`   | Symbol outline sidebar (aerial.nvim)                                           | nothing (better with a language server)                                     | `<leader>o`                    |
| `tasks`     | Run make / npm / cargo / just / `tasks.json` tasks (overseer.nvim)             | the task runner itself                                                      | `<leader>mr` `mt` `ml` `mq`    |
| `test`      | Test explorer: Python, JS (jest, vitest), Go, Rust, C++ (GoogleTest) (neotest) | the test tool in the project (`pytest`, `jest`, `go`, `cargo-nextest`, ...) | `<leader>n…`                   |
| `ui`        | Indent guides and sticky scroll (indent-blankline, treesitter-context)         | nothing                                                                     | none                           |
| `history`   | Visual undo tree (undotree)                                                    | nothing                                                                     | `<leader>u`                    |
| `git-ui`    | lazygit in a floating terminal                                                 | `lazygit`, `git`                                                            | `<leader>gg`                   |
| `github`    | GitHub pull requests and issues (octo.nvim)                                    | `gh` CLI, logged in                                                         | `<leader>Gp` `Gi` `Gr`         |
| `preview`   | Markdown in the browser; images in the terminal                                | `node`; for images a kitty-graphics terminal and ImageMagick                | `<leader>pm`                   |
| `java`      | Java through jdtls (nvim-jdtls)                                                | a JDK; Mason installs jdtls                                                 | none (the LSP keys)            |
| `ai`        | An AI assistant CLI in a side terminal                                         | the command in `vim.g.loki_ai_cmd`                                          | `<leader>aa`                   |

Prefixes added by extras (declared only while the extra is enabled): `s`
Session, `k` Clients, `t` Debug, `g` Git views, `m` Make / tasks, `n` Tests, `G` GitHub, `p` Preview, `a` AI assistant.
`surround` uses the `gs` prefix.

## sessions

Uses `folke/persistence.nvim`. The session of the current folder (and git
branch) is saved when you quit. It is **never** restored automatically:

| Key          | Action                             |
| ------------ | ---------------------------------- |
| `<leader>ss` | Restore the session of this folder |
| `<leader>sl` | Restore the last session           |
| `<leader>sd` | Do not save this session           |

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
chaining, `.env` files, URLs other than http(s). Prefer a full client? Add one from `lua/user/plugins/`.

## dap

Uses `nvim-dap`, `nvim-dap-ui` and `nvim-nio`. Mason installs the adapters
`debugpy`, `codelldb`, `js-debug-adapter` and `delve`. Launch setups are built in
for Python, C, C++, Rust, JavaScript, TypeScript and Go; there are also
"with arguments" variants (Python, C, C++, Rust), attach to debugpy (Python) and
attach to port 9229 (Node). The UI opens when a session starts and closes when
it ends.

**`.vscode/launch.json`** in the current folder is read when the debugger first
loads and again whenever the working directory changes. Its entries appear in
the `<leader>tc` picker. Supported `type` values: `python`, `debugpy`, `codelldb`, `cppdbg`, `pwa-node`, `node`, `delve`, `go`.
Other types are ignored. `cppdbg` runs through codelldb, so gdb-specific fields
(`miDebuggerPath`, `setupCommands`, `MIMode`) are ignored. For `go`, use
`"mode": "debug"` or `"test"`; `"auto"` is not understood by delve.

| Key                       | Action                                            |
| ------------------------- | ------------------------------------------------- |
| `<leader>tb` / `<F9>`     | Toggle breakpoint                                 |
| `<leader>tB`              | Conditional breakpoint (asks for an expression)   |
| `<leader>tl`              | Logpoint (prints a message, does not stop)        |
| `<leader>tc` / `<F5>`     | Start / continue                                  |
| `<leader>tr`              | Run to the cursor line                            |
| `<leader>tR`              | Restart the session                               |
| `<F10>` `<F11>` `<S-F11>` | Step over / into / out                            |
| `<leader>te`              | Evaluate under the cursor (Visual: the selection) |
| `<leader>tu`              | Toggle the debug UI                               |
| `<leader>tx`              | Stop                                              |

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

| Key          | Action               |
| ------------ | -------------------- |
| `<leader>cl` | Lint this buffer now |

Add a linter in `lua/config/languages_local.lua`, for example
`javascript = { lsp = "ts_ls", parser = "javascript", linter = "eslint_d", tools = { "eslint_d" } },`
(linter names are nvim-lint names, `tools` are Mason package names).
Common failure: nothing happens, because the program is not on `PATH`
(`:Mason`, then restart).

## surround

Uses `echasnovski/mini.surround` with the `gs` prefix (the default `s` prefix would
make the plain `s` key wait). Keys that wrap or unwrap text:

| Key                        | Action                 | Example                                     |
| -------------------------- | ---------------------- | ------------------------------------------- |
| `gsa` + motion + character | Add surrounding        | `gsaiw)` puts parentheses around the word   |
| `gsa` (Visual) + character | Surround the selection | select, `gsa"`                              |
| `gsd` + character          | Delete surrounding     | `gsd"` removes the quotes around the cursor |
| `gsr` + old + new          | Replace surrounding    | `gsr"'` turns `"` into `'`                  |

`gsf`, `gsF`, `gsh` and `gsn` find, highlight and change the search range
(`:help MiniSurround`). Common failure: a delay after `gs` is the popup waiting
for the next key.

## diffview

Uses `sindrets/diffview.nvim`. The closest thing to VS Code's Source Control
panel and Timeline: `gitsigns` (always on) handles single hunks, Diffview shows
the whole change set.

| Key          | Action                                            |
| ------------ | ------------------------------------------------- |
| `<leader>gd` | Diff view of every changed file, with a file list |
| `<leader>gh` | History of this file: each commit that touched it |
| `<leader>gq` | Close the Diffview tab                            |

Inside the file list `-` stages or unstages a file, `<Tab>` / `<S-Tab>` move
between files and `g?` lists every key. Files with merge conflicts open a 3-way
view (`:help diffview-merge-tool`). Committing is still done in a terminal (`<C-\>`).

## replace

Uses `MagicDuck/grug-far.nvim`. `<leader>R` opens a buffer with a search
field, a replacement field and a live list of matches across the project. Edit
the replacement, then press `<localleader>r` inside that buffer (the local
leader is `,` here, so `,` then `r`) to apply it; `g?` lists its keys. In Visual mode the selection
becomes the search text. Needs `ripgrep`. `:GrugFar` is the same as the key.

## outline

Uses `stevearc/aerial.nvim`. `<leader>o` toggles a sidebar of the functions,
classes and headings of the file (from the language server, then tree-sitter,
then Markdown headings). `<CR>` jumps, `{` / `}` move between symbols, `?`
lists its keys, `q` closes it.

## tasks

Uses `stevearc/overseer.nvim`. It finds tasks in `Makefile`, `package.json`,
`Cargo.toml`, `justfile`, `.vscode/tasks.json` and more.

| Key          | Action                           |
| ------------ | -------------------------------- |
| `<leader>mr` | Pick a task and run it           |
| `<leader>mt` | Toggle the task list and output  |
| `<leader>ml` | Run the last task again          |
| `<leader>mq` | Show task errors (quickfix list) |

Add your own task templates from `lua/user/plugins/` with an overseer `opts`
table (`:help overseer-templates`).

`<leader>ml` runs the last task again; `<leader>mq` opens the quickfix list, where
task output lands. Tasks from `.vscode/tasks.json` are given components that
send their output to the quickfix list (parsed with `errorformat`) and show
errors as diagnostics, so `]d` and `:cnext` walk them.

**What `tasks.json` support covers** was not checked against overseer's guide.
Before you rely on `dependsOn`, `problemMatcher` or `${input:...}` variables,
test a small `tasks.json` and read `:help overseer-guides`.

## test

Uses `nvim-neotest/neotest`. Adapters: `neotest-python` (pytest / unittest),
`neotest-jest`, `neotest-vitest`, `neotest-golang`, `neotest-rust` and
`neotest-gtest`. Each is loaded with `pcall`, so a broken one only prints a
warning. The sign column marks each test passed or failed.

| Key          | Action                                                             |
| ------------ | ------------------------------------------------------------------ |
| `<leader>nn` | Run the test nearest the cursor                                    |
| `<leader>nf` | Run every test in this file                                        |
| `<leader>ns` | Toggle the test explorer                                           |
| `<leader>no` | Show the output of the nearest test                                |
| `<leader>nx` | Stop the running tests                                             |
| `<leader>nl` | Run the last test again                                            |
| `<leader>nd` | Debug the nearest test (only when the `dap` extra is also enabled) |

Rust needs `cargo-nextest` (`cargo install cargo-nextest`). Go debugging also
needs `nvim-dap-go`; check each adapter's README for its debug support.

**Add an adapter** without editing shipped files. Install its plugin from
`lua/user/plugins/`, then in `lua/user/options.lua`:

```lua
vim.api.nvim_create_autocmd("User", {
    pattern = "LokiNeotestAdapters",
    callback = function()
        table.insert(require("util.extras").neotest_adapters, require("neotest-rspec"))
    end,
})
```

`User LokiNeotestSetup` still fires after `neotest.setup`. Common failure:
nothing runs because the test tool (`pytest`, `jest`, `go`, `cargo nextest`) is
not available in the project (activate the virtualenv, or run `npm install`,
before starting Neovim).

## ui

Uses `lukas-reineke/indent-blankline.nvim` and
`nvim-treesitter/nvim-treesitter-context`. No keys. Indent guides are drawn as
thin vertical lines; sticky scroll pins up to three lines (the function or class
you are inside) at the top of the window. `:IBLToggle` and `:TSContextToggle`
switch them for the session. Sticky scroll needs a parser for the filetype.

## history

Uses `mbbill/undotree`. `<leader>u` shows every state of the file as a tree
with a diff of the selected state; `<CR>` restores it. Persistent undo is on
(`undofile`), so the history survives restarts.

## git-ui

No plugin: `<leader>gg` runs `lazygit` in a floating terminal (the same helper
as `docker`). `jk`, `<Esc>` and `<C-h/j/k/l>` go to lazygit; quit it with `q`.
It is not an in-editor buffer. If you prefer one (Neogit), add it from
`lua/user/plugins/`. Committing and pushing happen inside lazygit, so no more
`<leader>g` keys are shipped. For merge conflicts use the `diffview` extra's
3-way view (`<leader>gd`, then open a conflicted file).

## github

Uses `pwntester/octo.nvim` with Telescope. Needs the GitHub CLI: install `gh`,
run `gh auth login`; `:checkhealth loki` reports both. The token stays in
`gh`'s own store, never in `lua/user/`.

| Key          | Action                                        |
| ------------ | --------------------------------------------- |
| `<leader>Gp` | List pull requests                            |
| `<leader>Gi` | List issues                                   |
| `<leader>Gr` | Start a review (inside a pull request buffer) |

`:Octo` has many more actions (`:Octo pr create`, `:Octo issue create`, ...);
type `:Octo ` and press `<Tab>`. `:checkhealth octo` verifies the plugin.
Octo's buffer-local keys use `<localleader>`, which is `,` here, so they
never collide with your Space `<leader>` keys.

## preview

Two parts. `<leader>pm` toggles a live Markdown preview in your browser
(`iamcco/markdown-preview.nvim`; installs with npm on first load; works in any
terminal that has a browser). Images are drawn inside the terminal by
`3rd/image.nvim`, only when the terminal looks like kitty, WezTerm or Ghostty
(`KITTY_WINDOW_ID`, `WEZTERM_PANE`, `GHOSTTY_RESOURCES_DIR` or `TERM`) and
ImageMagick is installed; in any other terminal that plugin is not loaded at
all. Inside `tmux` images need passthrough to be enabled. PDF display is not
provided. `:checkhealth loki` reports what the current terminal can do.

## java

Not a language-table line: jdtls is started per buffer by `nvim-jdtls`, with one
workspace folder per project under `stdpath("cache")/jdtls/`. Mason installs the
`jdtls` package; you need a JDK. The normal LSP keys (`gd`, `gr`, `K`,
`<leader>rn`, ...) attach as usual and `<leader>cf` formats through the server.
Settings, extra bundles (debug, test) and Lombok are not configured: add them in
`lua/user/plugins/` by extending the `nvim-jdtls` spec. Java debugging and
tests need those bundles and are not covered by the `dap` or `test` extras.

## ai

No plugin: `<leader>aa` toggles the command in `vim.g.loki_ai_cmd` in a terminal
on the right ([AI.md](AI.md)). It keeps running while hidden; leave it with
`<C-h>`.

## Persistent terminals (detach / reattach)

Not implemented as a feature. The dependable way is to run Neovim itself inside
`tmux` or `zellij`: detach with the multiplexer, and the editor, its terminals
and their running commands survive. Inside Neovim, `<C-\>` and `2<C-\>` keep
working as usual. Wrapping each toggleterm shell in `dtach` or `abduco` is
possible but needs per-terminal sockets, so it was left out until it can be
tested.

## Not shipped (needs a decision)

- **In-editor AI assistant** (inline edits, chat buffers): depends on the vendor you pick (`claudecode.nvim`,
  `codecompanion.nvim`, Copilot, ...). The `ai` extra only opens an assistant CLI in a side terminal
  ([AI.md](AI.md)). Keys would come from environment variables only.
- **Tree-sitter text objects for function definitions** (`af`/`if`): needs `nvim-treesitter-textobjects`; see [TREESITTER_MIGRATION.md](TREESITTER_MIGRATION.md) for the branch plan first.
- **Windows installer**: the supported route is WSL ([INSTALL.md](INSTALL.md)).
