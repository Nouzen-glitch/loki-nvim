# Getting Started

Your first 15 minutes, and the few things that are easy to miss. Everything
here is also available inside Neovim: `:LokiHelp` (one screen) and
`:LokiTutor` (practice).

## 1. Install it the right way

```bash
git clone https://github.com/Nouzen-glitch/loki-nvim ~/dotfiles/nvim
~/dotfiles/nvim/scripts/install.sh
```

Use the script instead of cloning into `~/.config/nvim` yourself. It backs up
any config you already have, can install alongside it (`nvim-loki`), gives you
an undo (`scripts/uninstall.sh`) and saves a safety copy of your personal files.
Add `--dry-run` first to see what it would do.

**Keep the folder you cloned into.** The config is a link to it, and your
personal files live inside it.

Check the requirements in [README.md](README.md) first (Neovim 0.11+, git, a C
compiler, ripgrep, Node.js and npm, Python 3, a Nerd Font). `:checkhealth loki`
lists whatever is missing.

## 2. First launch

Start Neovim (`nvim`, or `nvim-loki` for an alongside install). Plugins install
on their own; give it a minute. A window explains what the installer did. Then:

```vim
:checkhealth loki   " missing tools, install state, your files, key conflicts
:LokiHelp           " one-screen guide
:LokiTutor          " 10-minute practice tutorial
```

New to Vim itself? `:Tutor` is Neovim's own tutorial. Do it first.

## 3. Finding things (you never need to memorize keys)

| Key | What |
| --- | --- |
| `<leader>?` | Every key, grouped (`<leader>` is the Space bar) |
| `<leader>fk` | Search all keymaps |
| `<leader>fc` | Search all commands |
| `<leader>fC` | The generated cheatsheet |
| `<leader>fi` | The Loki guide (`:LokiHelp`; `:LokiHelp lsp` etc. for a topic) |

## 4. Make it yours

Never edit shipped files; that blocks updates. Your changes go in
`lua/user/`, created for you by:

```vim
:LokiEdit options     " settings, vim.g.loki_* switches
:LokiEdit keymaps     " your keys (always add desc)
:LokiEdit plugins     " extra plugins, tweaks to shipped ones
:LokiEdit languages   " add a language
```

If a key of yours replaces a shipped key, you are told once at startup;
`:LokiKeys` lists them. See [MIGRATING.md](MIGRATING.md) for details.

Optional features (session restore, a start screen, Docker, database and REST
clients, debugging) are off until you enable them: `:LokiExtras` lists them,
[EXTRAS.md](EXTRAS.md) explains each.

## 5. Keep your files safe (the step people forget)

`lua/user/` is **not in git**, so a fresh clone does not contain it.

| When | Do |
| --- | --- |
| Before deleting or re-cloning the repo, reinstalling the OS | `:LokiBackup` or `scripts/user-layer.sh export FILE` |
| On a new machine | clone, `scripts/install.sh`, then `scripts/user-layer.sh import FILE` |
| Something vanished | `scripts/user-layer.sh backups`, then `import` the newest |

`install.sh` and `update.sh` save a safety copy to
`~/.local/state/loki-backups/` (newest 10 kept) before changing anything.
Reinstalling the Neovim package itself never touches your files.

## 6. Keep it current

```bash
scripts/update.sh --check   # what is coming?
scripts/update.sh           # apply
```

Plugins update separately: `:Lazy`, then `U`.

## 7. Do and don't

| Do | Don't |
| --- | --- |
| Install with `scripts/install.sh` | Clone straight into `~/.config/nvim` |
| Put changes in `lua/user/` | Edit `lua/config/` or `lua/plugins/` |
| Export before wiping anything | Run `git clean -fdx` (deletes your ignored personal files) |
| Give every keymap a `desc` | Map a key that is the start of another key |
| Run `:checkhealth loki` when something is off | Ignore the startup notice about replaced keys |

## 8. Where next

Feature pages: [LSP.md](LSP.md), [FINDING.md](FINDING.md), [GIT.md](GIT.md),
[FILES.md](FILES.md), [TERMINAL.md](TERMINAL.md), [COMPLETION.md](COMPLETION.md);
[CONCEPTS.md](CONCEPTS.md) explains buffers, registers, marks and the rest;
[TROUBLESHOOTING.md](TROUBLESHOOTING.md) lists every symptom. In the editor:
`:LokiHelp <topic>` or `:help loki`.


[KEYBINDINGS.md](KEYBINDINGS.md) (learning order), [INSTALL.md](INSTALL.md)
(every flag), [MIGRATING.md](MIGRATING.md) (bring your old config),
[ADDING_LANGUAGES.md](ADDING_LANGUAGES.md).
