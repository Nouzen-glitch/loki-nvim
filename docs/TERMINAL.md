# The integrated terminal

## What it does

`toggleterm.nvim` gives a terminal at the bottom of the editor that keeps
running when hidden.

## Keys

| Key | Action |
| --- | --- |
| `<C-\>` | Toggle the terminal, from any mode |
| `2<C-\>`, `3<C-\>` | Toggle numbered terminals |
| `:TermSelect` | Pick a terminal from a list |
| `jk` or `<Esc>` | Terminal mode to Normal mode (scroll, search) |
| `i` / `a` | Back to typing |
| `<C-h/j/k/l>` | Leave the terminal to that window |

`jk`, `<Esc>` and `<C-h/j/k/l>` apply to the toggleterm terminal only. Other
terminals (`:terminal` running lazygit, fzf, vim) keep every key for the program.

Example: `<C-\>`, run `git status`, `jk` to scroll, `<C-\>` to hide it.

## Persistent terminals

Not built in. Run Neovim inside `tmux` or `zellij` and detach with the
multiplexer ([EXTRAS.md](EXTRAS.md#persistent-terminals-detach--reattach)).

## Common failures

| Symptom | Cause and fix |
| --- | --- |
| `<C-\>` does nothing | Your terminal or another program took it. Rebind with toggleterm `opts` ([MIGRATING.md](MIGRATING.md), section 4) |
| `jk` / `Esc` do nothing in lazygit | By design: only the toggleterm terminal uses them |
| Backspace moves windows | Your terminal sends `<C-h>` for Backspace; see [KEYBINDINGS.md](KEYBINDINGS.md#windows-and-buffers) |

## Where next

[PLUGIN_KEYS.md](PLUGIN_KEYS.md#toggleterm), [GIT.md](GIT.md), `:LokiHelp terminal`.
