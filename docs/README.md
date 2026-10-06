# Loki Neovim IDE

> The repository is `loki-nvim` (https://github.com/Nouzen-glitch/loki-nvim). The project was
> called *Elite Neovim* before; if you installed it under that name see the upgrade notes in
> [../CHANGELOG.md](../CHANGELOG.md) (2026-10-04).

A structured Neovim configuration that keeps Vim's modal editing and adds the
parts of VS Code that matter for programming: LSP IntelliSense, diagnostics,
completion, fuzzy finding, git hunks, formatting, and an integrated terminal.

Targets Neovim 0.11+ (currently running 0.12.x) on Linux (developed on Fedora). On Windows, use WSL 2.

## Docs

| File | Read it for |
| --- | --- |
| [GETTING_STARTED.md](GETTING_STARTED.md) | Start here: your first 15 minutes, what to do and what to avoid |
| [INSTALL.md](INSTALL.md) | Installing (alongside or replace), every script and flag, updating, undoing, troubleshooting |
| [MIGRATING.md](MIGRATING.md) | Customizing without editing shipped files; bringing your own config and plugins |
| [KEYBINDINGS.md](KEYBINDINGS.md) | Every custom key, grouped by task, plus a learning order |
| [PLUGIN_KEYS.md](PLUGIN_KEYS.md) | Keys inside Telescope, nvim-tree, Trouble, toggleterm, gitsigns |
| [LSP.md](LSP.md) | Go to definition, rename, diagnostics, formatting, `:LokiLsp` |
| [COMPLETION.md](COMPLETION.md) | Completion menu and snippets |
| [FINDING.md](FINDING.md) | Telescope pickers and the key popup |
| [FILES.md](FILES.md) | The file explorer |
| [GIT.md](GIT.md) | Hunks, stage, blame, diff |
| [TERMINAL.md](TERMINAL.md) | The integrated terminal |
| [CONCEPTS.md](CONCEPTS.md) | Buffers, windows, registers, marks, quickfix, macros, folds |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Every symptom with its cause and fix |
| [VSCODE_GAP.md](VSCODE_GAP.md) | Honest comparison with VS Code: what is covered, what was added, what is still missing |
| [TREESITTER_MIGRATION.md](TREESITTER_MIGRATION.md) | Plan (not done): nvim-treesitter `master` to `main` |
| [ADDING_LANGUAGES.md](ADDING_LANGUAGES.md) | Adding a language: one line, nothing installed unless listed |
| [COMPONENTS.md](COMPONENTS.md) | What each plugin/tool is and which file configures it |
| [ENVIRONMENT_GUIDE.md](ENVIRONMENT_GUIDE.md) | Maintaining the config: workflow, git, cheatsheet automation, known issues |
| [EXTRAS.md](EXTRAS.md) | Opt-in features: sessions, dashboard, docker, database, REST, debugging, tests, tasks, GitHub, Java, previews |
| [AI.md](AI.md) | Using an AI assistant: terminal route, the `ai` extra, plugins |
| [REMOTE.md](REMOTE.md) | Working over SSH, in containers and WSL; clipboard over SSH |
| [../CHANGELOG.md](../CHANGELOG.md) | What changed, newest first (`scripts/update.sh` prints new entries) |

In the editor the same keys and commands are available as `:LokiHelp [topic]` and offline as
`:help loki` (generated from `lua/util/registry.lua`, see [ENVIRONMENT_GUIDE.md](ENVIRONMENT_GUIDE.md) section 4b).

The live cheatsheet is **generated** from the running editor (`<leader>fC` or
`:Cheatsheet`). It is stored in Neovim's state folder, not in this repo.

## Requirements

- Neovim 0.11+, `git`, a C compiler and `make` (Tree-sitter, LuaSnip, fzf-native)
- `ripgrep` (Telescope live grep), `curl`, `unzip` (Mason)
- A clipboard tool (`wl-clipboard` or `xclip`): yank and paste use the system clipboard
- A Nerd Font in your terminal (icons)
- Node.js + npm, Python 3, and optionally Go: Mason uses them to install language servers and formatters
- `rustup` if you use Rust: `rustfmt` comes with it (it is not a Mason package)

```bash
# Fedora
sudo dnf install neovim git ripgrep gcc gcc-c++ make curl unzip nodejs npm python3 golang wl-clipboard xclip
# Arch
sudo pacman -S neovim git ripgrep base-devel curl unzip nodejs npm python go wl-clipboard xclip
```

## Install

```bash
git clone https://github.com/Nouzen-glitch/loki-nvim ~/dotfiles/nvim
~/dotfiles/nvim/scripts/install.sh
```

Always install with `scripts/install.sh` rather than cloning straight into
`~/.config/nvim`: the script gives you undo, a backup of your old config, a
safety copy of your personal files and the `nvim-loki` launcher. Your personal
files (`lua/user/`) live inside the cloned folder and are not in git, so keep
that folder, and run `scripts/user-layer.sh export` (or `:LokiBackup`) before
deleting or re-cloning it.

The installer never deletes anything. If you already have a Neovim config it
asks how to proceed:

| Choice | Result |
| --- | --- |
| **Alongside** (default, safest) | Run this config with `nvim-loki`. Your current `nvim` and its plugins are not touched. |
| **Replace** | This becomes `nvim`. Your old config is moved to `~/.config/nvim.backup.<timestamp>`. |

| Script | Purpose |
| --- | --- |
| `scripts/install.sh` | Install. Flags: `--alongside`, `--replace`, `--appname NAME`, `--clean-data`, `--dry-run`, `--yes` |
| `scripts/uninstall.sh` | Remove the link and launcher, restore your backup. Flags: `--appname`, `--dry-run`, `--yes` |
| `scripts/update.sh` | Pull the latest config and show what changed. Flag: `--check` |
| `scripts/user-layer.sh` | `list`, `export`, `import`, `backup`, `backups` for your personal files (not in git) |

What every flag does, worked scenarios (first install, trying it out, switching,
updating, a second machine, undoing) and troubleshooting are in
[INSTALL.md](INSTALL.md). Add `--dry-run` to see what would happen first.

First launch checklist:

```vim
:Lazy              " plugins installed?
:Mason             " servers and tools from config/languages.lua
:checkhealth loki " tools, versions, install state
:LokiInfo         " how this config was installed, where any backup is
:LokiHelp         " one-screen guide: what you can do and should do
:LokiTutor        " short practice tutorial
```

## Layout

```text
~/dotfiles/nvim/
├── init.lua                  entry point (keep tiny)
├── lazy-lock.json            plugin versions the maintainer tested (seeds each user's personal copy)
├── CHANGELOG.md              what changed, newest first
├── .gitignore                keeps your personal layer out of git
├── docs/                     README, GETTING_STARTED, INSTALL, MIGRATING, KEYBINDINGS, ADDING_LANGUAGES, COMPONENTS, ENVIRONMENT_GUIDE, EXTRAS
├── scripts/
│   ├── install.sh            alongside or replace install, with backup and dry-run
│   ├── uninstall.sh          removes the link, restores your backup
│   ├── update.sh             pulls updates, shows what changed
│   ├── user-layer.sh         export/import your personal files
│   ├── smoke-test.sh         headless check that the modules load; runs check-help.sh (for maintainers)
│   ├── check-help.sh         fails when keys, commands, docs or doc/loki.txt drift apart
│   ├── gen-help.sh           regenerates doc/loki.txt from the registry
│   ├── install-watcher.sh    installs the optional systemd cheatsheet watcher
│   └── generate-cheatsheet.sh  headless cheatsheet regeneration
├── doc/loki.txt              :help loki (generated by scripts/gen-help.sh; doc/tags is generated at startup)
├── systemd/                  unit templates for the optional cheatsheet watcher
└── lua/
    ├── config/
    │   ├── options.lua       editor behavior, leader = Space
    │   ├── keymaps.lua       custom keybindings
    │   ├── autocmds.lua      yank highlight, cursor restore, diagnostic display
    │   ├── languages.lua     default languages: LSP, parser, formatter, tools
    │   ├── presets.lua       opt-in language presets (vim.g.loki_language_presets)
    │   ├── languages_local.lua  YOUR additions (optional, you create it, gitignored)
    │   ├── lazy.lua          lazy.nvim bootstrap
    │   └── leader_groups.lua leader namespaces (feeds which-key and the cheatsheet)
    ├── plugins/              one spec file per concern
    │   ├── completion.lua  formatting.lua  git.lua  lsp.lua
    │   ├── telescope.lua  terminal.lua  textobjects.lua
    │   └── treesitter.lua  ui.lua
    ├── extras/               opt-in feature specs: sessions, dashboard, database, dap, lint, surround, diffview, replace, outline, tasks, test, ui, history, git-ui, github, preview, java, ai (see docs/EXTRAS.md)
    ├── user/                 YOUR options, keymaps and plugins (gitignored; *.example files show how)
    ├── loki/
    │   └── health.lua        :checkhealth loki
    └── util/
        ├── cheatsheet.lua    cheatsheet generator (:Cheatsheet, :CheatsheetUpdate)
        ├── languages.lua     derives plugin lists from config/languages.lua
        ├── lockfile.lua      personal plugin lockfile (:LokiLockReset)
        ├── user.lua          loads your lua/user/ files, reports errors in them
        ├── keyguard.lua      reports shipped keys your keymaps replace (:LokiKeys)
        ├── guide.lua         :LokiHelp, :LokiTutor, :LokiEdit, :LokiBackup, :LokiExtras
        ├── registry.lua      SINGLE SOURCE OF TRUTH: every key, command and help topic
        ├── helpdoc.lua       renders :LokiHelp topics and doc/loki.txt from the registry
        ├── lsp.lua           buffer-local LSP keys on LspAttach, :LokiLsp
        ├── check_help.lua    the checks behind scripts/check-help.sh
        ├── smoke.lua         the checks behind scripts/smoke-test.sh
        ├── extras.lua        registry of opt-in extras and their checks
        ├── rest.lua          .http request runner for the rest extra
        └── welcome.lua       first-run install window, :LokiInfo
```

Where to change things:

| Want to change | Edit |
| --- | --- |
| Anything just for you | `lua/user/` (options, keymaps, plugins), see [MIGRATING.md](MIGRATING.md) |
| Updating this config | `scripts/update.sh`, see [INSTALL.md](INSTALL.md) |
| Editor behavior (project default) | `config/options.lua` |
| Keybindings (project default) | `util/registry.lua` (`config/keymaps.lua` only creates them) |
| Automatic behavior | `config/autocmds.lua` |
| Leader group labels | `config/leader_groups.lua` |
| Languages (LSP, syntax, formatting) | `config/languages_local.lua` for yours, `config/languages.lua` for defaults (see ADDING_LANGUAGES.md) |
| Completion, snippets | `plugins/completion.lua` |
| Appearance, explorer | `plugins/ui.lua` |
| Terminal | `plugins/terminal.lua` |
| LSP servers, Mason tools | `plugins/lsp.lua` (server list comes from the language table) |
| Formatting, format on save | `plugins/formatting.lua` |
| Fuzzy finder | `plugins/telescope.lua` |
| Syntax highlighting | `plugins/treesitter.lua` |
| Git signs | `plugins/git.lua` |
| Text objects, auto-pairs, which-key labels | `plugins/textobjects.lua` |
| Any key's description or help text, command help, help topics | `util/registry.lua`, then `scripts/gen-help.sh` |
| Opt-in features (sessions, dashboard, docker, database, rest, dap, lint, surround, diffview, replace, outline, tasks, test, ui, history, git-ui, github, preview, java, ai) | `vim.g.loki_extras` in `lua/user/options.lua`; specs in `extras/`, registry in `util/extras.lua` |

## Day-one essentials

Leader is **Space**. `jk` exits Insert mode. Arrow keys are disabled on purpose
(`vim.g.loki_disable_arrows = false` in `lua/user/options.lua` turns that off).

| Key | Action |
| --- | --- |
| `<leader>ff` / `<leader>fg` | Find files / search project |
| `gd` `gr` `K` | Definition / references / hover docs |
| `<leader>rn` `<leader>ca` | Rename / code action |
| `<leader>cf` | Format (also runs on save) |
| `<C-s>` | Save |
| `<leader>e` | File explorer |
| `<C-\>` | Toggle terminal |
| `<leader>?` | Show every keybinding (which-key) |
| `<leader>fC` | Open the generated cheatsheet |
| `<leader>fi` / `:LokiHelp` | One-screen guide: what you can do and should do |

Full list: [KEYBINDINGS.md](KEYBINDINGS.md).

## Health checks

```vim
:checkhealth loki      :checkhealth vim.lsp     :checkhealth mason
:checkhealth nvim-treesitter                     :ConformInfo
:Lazy                   :Mason
```

## Not included (yet)

AI assistants (the vendor is your choice), built-in persistent terminal
sessions (run Neovim inside tmux or zellij, see [EXTRAS.md](EXTRAS.md)) and a
native Windows installer (use WSL, see [INSTALL.md](INSTALL.md)).
Session restore, a dashboard, Docker, database and REST clients, DAP
debugging, linting and surround exist as opt-in [extras](EXTRAS.md) (`vim.g.loki_extras`).
Multiple numbered terminals are supported via toggleterm (`2<C-\>`, `:TermSelect`).
Anything else can be added through `lua/user/plugins/`.
AI assistants and remote development are documented, not built in: [AI.md](AI.md), [REMOTE.md](REMOTE.md).
