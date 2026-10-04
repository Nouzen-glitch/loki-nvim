# Install, Update, Undo

Everything about putting this config on a machine, keeping it current, and
taking it off again. Customizing it and bringing your own config along is in
[MIGRATING.md](MIGRATING.md).

Supported: Linux (developed on Fedora). On Windows use **WSL 2** with a Linux distribution
(install and run everything inside WSL; use a Nerd Font in the Windows terminal). A native Windows
installer does not exist, and macOS is untested: the scripts rely on GNU tools (`date -Is`).

## 1. Quick start

```bash
git clone https://github.com/Nouzen-glitch/loki-nvim ~/dotfiles/nvim
~/dotfiles/nvim/scripts/install.sh
```

The installer never deletes anything and changes nothing until you confirm. Add
`--dry-run` first if you want to see exactly what it would do.

| Your situation | What the installer does |
| --- | --- |
| No existing Neovim config | Links this repo as your `nvim` config. Nothing to back up. |
| You already have a config (interactive) | Asks: **1** alongside (default), **2** replace, **3** cancel. |
| You already have a config (`--yes`, or no terminal) | Installs **alongside**, the safe choice. |

After installing, start Neovim. The first launch installs plugins (about a
minute) and shows a window explaining what the installer did. Then run
`:checkhealth loki`.

Then run `:LokiHelp` (one screen) and `:LokiTutor` (practice), or read
[GETTING_STARTED.md](GETTING_STARTED.md). **Keep the folder you cloned into:**
the config is a link to it, and your personal files (`lua/user/`, not in git)
live inside it. Save them (`scripts/user-layer.sh export` or `:LokiBackup`)
before deleting or re-cloning it.

## 2. The two install modes

| | Alongside | Replace |
| --- | --- | --- |
| Start it with | `nvim-loki` | `nvim` |
| Your current `nvim` | Untouched | Old config moved to a backup |
| Config folder | `~/.config/loki` | `~/.config/nvim` |
| Plugins and data | `~/.local/share/loki` | `~/.local/share/nvim` |
| State | `~/.local/state/loki` | `~/.local/state/nvim` |
| Cache | `~/.cache/loki` | `~/.cache/nvim` |
| Best for | Trying it out; keeping two setups | Making this your only setup |

Alongside mode uses Neovim's `NVIM_APPNAME` setting, which swaps the folder
name `nvim` for another in all four places, so the two setups cannot interfere.
`nvim-loki` is a tiny launcher script the installer writes to `~/.local/bin`.

Config, data, state and cache honor `XDG_CONFIG_HOME`, `XDG_DATA_HOME`,
`XDG_STATE_HOME` and `XDG_CACHE_HOME` if you have set them. The launcher folder
is always `~/.local/bin`.

Reinstalling or upgrading the Neovim package itself (dnf, pacman, apt) does not
touch any of these folders. Your config, the symlink, and your plugins stay as
they were.

## 3. `scripts/install.sh`

```text
scripts/install.sh [--alongside | --replace] [--appname NAME]
                   [--clean-data] [--dry-run] [--yes] [--help]
```

| Flag | What it does |
| --- | --- |
| `--alongside` | Install as its own app named `loki`. Launch with `nvim-loki`. Nothing of yours is touched. |
| `--replace` | Make this your `nvim` config. An existing `~/.config/nvim` is moved to `~/.config/nvim.backup.<timestamp>`, never deleted. |
| `--appname NAME` | Use `NAME` instead of `loki` (launcher becomes `nvim-NAME`, folders become `~/.config/NAME` etc.). Implies `--alongside`. Allowed characters: letters, digits, `.`, `_`, `-`. `nvim` is not allowed (use `--replace`). Cannot be combined with `--replace`. |
| `--clean-data` | Only with `--replace`. Also moves the old `~/.local/share/nvim`, `~/.local/state/nvim` and `~/.cache/nvim` to `*.backup.<timestamp>`, so leftovers from an older setup (for example packer plugins) cannot load under this config. Ignored, with a note, in other modes. |
| `--dry-run` | Print every step prefixed with `[dry-run]` and change nothing. The requirement checks still run. |
| `-y`, `--yes` | Ask nothing. If an existing config is found and no mode was given, installs alongside. |
| `-h`, `--help` | Show usage. |

What it checks first:

| Check | If it fails |
| --- | --- |
| `nvim` installed and version 0.11 or newer | Stops with an error. |
| `git` installed | Stops with an error. |
| `rg`, `make`, `curl`, `unzip`, `node`, `npm`, `python3`, a C compiler | Warns and continues; the affected features just will not work until installed. `:checkhealth loki` lists them later. |

Other behavior worth knowing:

- **Safe to re-run.** If the link already points at this repo it says
  "Already installed" and changes nothing.
- **Backups are moves, not copies or deletes.** The backup path is printed in
  the summary, shown in Neovim on first launch, and available any time with
  `:LokiInfo`.
- **A broken link** at the target (for example the repo was moved) is removed
  without a backup, since there is nothing to save.
- **Leftover data warning.** In replace mode, if `~/.local/share|state|cache/nvim`
  already existed before the installer ran, it warns that plugins from your
  previous setup can load under this config, and points at `--clean-data` or
  `--alongside`.
- **The launcher** `~/.local/bin/nvim-<name>` is only overwritten if the
  installer created it. If something else is there, it is left alone and you
  are told to use `NVIM_APPNAME=<name> nvim` instead. If `~/.local/bin` is not
  on your `PATH` you get a warning with the line to add.
- **The record** of what happened is written to
  `<state folder>/loki-install-info`. `uninstall.sh` and the first-run window
  read it.

## 4. `scripts/uninstall.sh`

```text
scripts/uninstall.sh [--appname NAME] [--dry-run] [--yes] [--help]
```

| Flag | What it does |
| --- | --- |
| `--appname NAME` | Undo the install with that name. Without it the script looks for `loki`, then `nvim`. |
| `--dry-run` | Show what would happen; change nothing; no questions. |
| `-y`, `--yes` | Do not ask for confirmation. Without it (and without `--dry-run`) it asks, and refuses to run when there is no terminal. |
| `-h`, `--help` | Show usage. |

What it does:

1. Finds the symlink that points at this repo. If there is none (for example
   you cloned straight into `~/.config/nvim`), it says there is nothing to
   uninstall.
2. Removes that link.
3. If the install moved an old config aside, moves it back. It reads the
   backup path from the install record; with no record it offers the newest
   `<config>.backup.*` it can find and says so.
4. Removes `~/.local/bin/nvim-<name>` if the installer created it.
5. Deletes the install record.

It handles **one install per run**. With both an alongside and a replace install
(scenario D), run it once with `--appname loki` and once with `--appname nvim`;
without `--appname` it stops at the first one it finds (`loki`, then `nvim`).

It does **not** delete plugin data. For an alongside install it lists the
`loki` data, state and cache folders so you can remove them for a clean
slate. For a replace install those folders are shared with your restored
config, so it leaves them alone; if you used `--clean-data`, it lists the
`*.backup.*` folders that you can move back by hand.

## 5. `scripts/update.sh`

```text
scripts/update.sh [--check] [--help]
```

| Flag | What it does |
| --- | --- |
| `--check` (alias `--dry-run`) | Show what is incoming and stop. Changes nothing. |
| `-h`, `--help` | Show usage. |

It fetches, lists the incoming commits, prints the new lines of
`CHANGELOG.md`, then fast-forwards. It stops without changing anything, and
tells you what to do, when:

| Situation | Message and fix |
| --- | --- |
| You edited a shipped file | Lists the files. `git stash` (then `git stash pop`) or commit them. Personal settings belong in `lua/user/`, which never blocks an update. |
| You have local commits that are not pushed | Run `git pull --rebase`. |
| The branch has no upstream | Gives the `git branch --set-upstream-to` command. |
| No network | Says so. |

When the shipped `lazy-lock.json` changed it also tells you how to adopt the
new plugin versions (section 8). Plugins themselves are updated separately:
`:Lazy`, then `U`.

Your personal files (`lua/user/`, `lua/config/languages_local.lua`) are
gitignored, so an update never touches them.

## 6. `scripts/user-layer.sh`

Moves your personal files between machines. See
[MIGRATING.md](MIGRATING.md) for what those files are.

```text
scripts/user-layer.sh list
scripts/user-layer.sh export [FILE]
scripts/user-layer.sh import FILE
scripts/user-layer.sh backup
scripts/user-layer.sh backups
```

| Command | What it does |
| --- | --- |
| `list` | Shows which personal files exist. |
| `export [FILE]` | Packs every file under `lua/user/` (except `*.example`, `.gitkeep`, `*.bak.*`) and `lua/config/languages_local.lua` into a `.tar.gz` (default `./loki-user-layer-<date>.tar.gz`). The `*.example` files are not included. Check for secrets before sharing it. |
| `import FILE` | Unpacks onto this machine. Any file it would overwrite is first renamed to `<name>.bak.<timestamp>`. It refuses archives containing anything outside `lua/user/` and `languages_local.lua`, or unsafe paths. |
| `backup` | Quiet safety copy to `~/.local/state/loki-backups/user-layer-<timestamp>.tar.gz`; the newest 10 are kept. Does nothing if you have no personal files. Run automatically by `install.sh` and `update.sh`. |
| `backups` | Lists the safety copies, newest first. Restore one with `import`. |

Safety copies are shared by every install (alongside or replace). `:LokiBackup`
inside Neovim is the same as `export` with a default path in your home folder.

## 7. Scenarios

### A. Brand-new user, no Neovim config

```text
$ git clone https://github.com/Nouzen-glitch/loki-nvim ~/dotfiles/nvim && ~/dotfiles/nvim/scripts/install.sh
 Loki Neovim: done (replace)
 Config   : ~/.config/nvim -> ~/dotfiles/nvim
 Nothing needed backing up.
 Start it : nvim   (first launch installs plugins; give it a minute)
$ nvim
```

Plugins, parsers and language servers install on their own; watch `:Lazy` and
`:Mason`. A window then explains what happened. Run `:checkhealth loki` to
see anything missing.

### B. Already has a config, wants to try this first

```text
$ scripts/install.sh            (press Enter for the default, 1)
 Loki Neovim: done (alongside)
 Config   : ~/.config/loki -> ~/dotfiles/nvim
 Your existing Neovim config was not touched.
 Launcher : ~/.local/bin/nvim-loki
$ nvim          # your old setup, exactly as before
$ nvim-loki    # this config, with its own plugins and state
```

### C. Wants to switch completely

```text
$ scripts/install.sh --replace --dry-run     # preview
$ scripts/install.sh --replace
 YOUR OLD CONFIG WAS MOVED TO:
   ~/.config/nvim.backup.20260930-101500
```

If the old setup used a different plugin manager, also pass `--clean-data` so
its leftover plugins do not load:

```text
$ scripts/install.sh --replace --clean-data
```

### D. Tried alongside, now wants it as the main `nvim`

```text
$ scripts/install.sh --replace
```

Their old `~/.config/nvim` is backed up as in C. The `nvim-loki` launcher and
the `~/.config/loki` link keep working until you run
`scripts/uninstall.sh --appname loki`.

### E. Bringing an old config and plugins along

Follow [MIGRATING.md](MIGRATING.md), section 2. In short: find the backup with
`:LokiInfo`, copy options, keymaps and plugin specs into `lua/user/`, restart.

### F. Updating

```text
$ scripts/update.sh --check     # what is coming?
$ scripts/update.sh             # apply it
```

Then restart Neovim. New plugins install automatically; run `:Lazy clean` to
remove ones that were dropped, and `:checkhealth loki` to verify. Alongside
installs update the same way, since `~/.config/loki` links to the same repo.

### G. Setting up a second machine

```text
# on machine 1
$ scripts/user-layer.sh export ~/loki-user.tar.gz
# on machine 2
$ git clone https://github.com/Nouzen-glitch/loki-nvim ~/dotfiles/nvim && ~/dotfiles/nvim/scripts/install.sh
$ ~/dotfiles/nvim/scripts/user-layer.sh import ~/loki-user.tar.gz
```

Plugin versions come from the shipped `lazy-lock.json`. (Alternatively, keep
`lua/user/` in your own private git repository.)

### H. Undoing everything

```text
$ scripts/uninstall.sh --dry-run    # preview
$ scripts/uninstall.sh
```

Replace mode: the link is removed and your old config is moved back. Alongside
mode: the link and the `nvim-loki` launcher are removed; your `nvim` was never
touched. Plugin data is left and listed (section 4).

### I. Reinstalling Neovim or the whole OS

Reinstalling the Neovim package changes nothing. After an OS reinstall, clone
the repo again, run the installer, and import your personal layer (G). Before
wiping a machine or deleting the repo folder, export first
(`scripts/user-layer.sh export` or `:LokiBackup`); the newest automatic
safety copies are in `~/.local/state/loki-backups/`.

## 8. Plugin versions (the lockfile)

`lazy-lock.json` in the repo lists the plugin versions the maintainer
tested. By default each user gets a **personal copy** of it in
`~/.local/share/<name>/loki-lazy-lock.json`, seeded from the repo on first
launch. Adding or updating plugins changes only the personal copy, so
`git pull` never conflicts.

| I want to... | Do this |
| --- | --- |
| Update my plugins | `:Lazy`, then `U`. |
| Go back to the versions shipped with the config | `:LokiLockReset`, restart, then `:Lazy restore`. |
| Commit the lockfile to the repo (maintainers) | Put `vim.g.loki_lockfile_in_repo = true` in `lua/user/options.lua`. |

## 9. Where things live

| What | Location |
| --- | --- |
| The repo (source of truth) | Wherever you cloned it, for example `~/dotfiles/nvim` |
| Active config (link to the repo) | `~/.config/nvim` (replace) or `~/.config/loki` (alongside) |
| Installed plugins, Mason tools, personal lockfile | `~/.local/share/<name>/` |
| Install record, generated cheatsheet | `~/.local/state/<name>/` |
| Safety copies of your personal files | `~/.local/state/loki-backups/` (shared by all installs) |
| Backup of your old config | `~/.config/nvim.backup.<timestamp>` |
| Launcher (alongside) | `~/.local/bin/nvim-<name>` |
| Your personal files | `lua/user/` and `lua/config/languages_local.lua` inside the repo (gitignored) |

`<name>` is `nvim` for replace and `loki` (or your `--appname`) for alongside.

## 10. Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| `nvim-loki: command not found` | `~/.local/bin` is not on your `PATH`. Add `export PATH="$HOME/.local/bin:$PATH"` to your shell profile, or run `NVIM_APPNAME=loki nvim`. |
| Installer says the launcher "exists and was not created by this installer" | Something else is at that path. Use `NVIM_APPNAME=<name> nvim`, or move that file and re-run. |
| Neovim starts empty or errors right after moving the repo | The link is now broken. Run `scripts/install.sh` from the new location (it removes the broken link). `uninstall.sh` cannot find a broken link; remove it by hand (`rm ~/.config/nvim`). |
| Plugins from my old setup are loading | They live in `~/.local/share/nvim`. Reinstall with `--replace --clean-data`, or use `--alongside`. |
| Icons show as boxes | Set a Nerd Font as your terminal's font. |
| `<leader>fg` (live grep) does nothing | Install `ripgrep` (`rg`). |
| Plugins fail to install on first start | Needs `git` and a network connection. Open `:Lazy` and press `I` to retry; read the error there. |
| Tree-sitter or fzf-native fails to build | Install a C compiler and `make`. |
| A language server will not install | Mason needs Node.js, Python 3 (and Go for some). `:MasonLog` shows the error; `:checkhealth loki` shows missing toolchains. |
| A server is installed but does not attach | Only servers in the language table are enabled. Add it to `lua/config/languages_local.lua` (see [ADDING_LANGUAGES.md](ADDING_LANGUAGES.md)). |
| Error at startup naming `user.options` or `user.keymaps` | A mistake in your own file; the message shows the file and line. The rest of the config still loads. A file that does not exist is fine. |
| `Failed to load user.plugins.<name>` | Same, for a file in `lua/user/plugins/`. |
| `update.sh` refuses to update | You edited a shipped file. `git stash` or commit, run it again. Put personal changes in `lua/user/`. |
| `git pull` complains about `lazy-lock.json` | You set `vim.g.loki_lockfile_in_repo = true` and the file changed locally. Commit it or `git checkout lazy-lock.json`. |
| I closed the first-run window and want it back | `:LokiInfo`. |
| Where is the cheatsheet? | `:Cheatsheet` opens it; it is stored in `~/.local/state/<name>/cheatsheet.md`. |
| Not sure what is wrong | `:checkhealth loki`, then `:checkhealth`. |
| My `lua/user/` files are gone after a re-clone | They are not in git. `scripts/user-layer.sh backups`, then `import` the newest, or import your own export. |
| Startup notice: "your keymaps replace N shipped keys" | `:LokiKeys` lists them; pick other keys or delete your lines ([MIGRATING.md](MIGRATING.md)). |
| A welcome notice about "not set up by install.sh" | The config was cloned by hand. It works; run `scripts/install.sh` for undo and safety copies, or set `vim.g.loki_hide_notices = true`. |
