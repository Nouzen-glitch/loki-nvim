# Git

## What it does

`gitsigns.nvim` compares each file with git and marks changed lines in the sign
column (`│` added or changed, `_` deleted, `~` changed and deleted). A **hunk**
is one contiguous block of changes. You can stage, reset, preview and blame
hunks without leaving the file.

## Keys

| Key | Action |
| --- | --- |
| `]h` / `[h` | Next / previous hunk |
| `<leader>hs` | Stage the hunk (Visual mode: only the selected lines) |
| `<leader>hr` | Reset the hunk, discarding the change (Visual mode: selected lines) |
| `<leader>hu` | Undo the last stage |
| `<leader>hp` | Preview the hunk in a float |
| `<leader>hb` | Blame the cursor line (author, date, message) |
| `<leader>hB` | Toggle blame text at the end of the cursor line |
| `<leader>hd` | Diff the file against the index, side by side |
| `<leader>fG` | Changed files in Telescope, with a diff preview |

Example: edit three lines, `]h` to the change, `<leader>hp` to review it,
`<leader>hs` to stage it. In Visual mode, select two of the lines and press
`<leader>hs` to stage just those. Then commit in a terminal (`<C-\>`).

Commands: `:Gitsigns` with a tab-completed action (for example
`:Gitsigns toggle_deleted`).

## Common failures

| Symptom | Cause and fix |
| --- | --- |
| No signs | Not a git repository, or the file is ignored. `git status` in the folder |
| Blame says "Not Committed Yet" | The line is new |
| `<leader>fG` shows nothing | No changed files, or not a repository |
| Stage keys do nothing in Visual mode | Press the key while the selection is active, not after leaving Visual mode |

## Where next

[PLUGIN_KEYS.md](PLUGIN_KEYS.md), [TERMINAL.md](TERMINAL.md), `:LokiHelp git`.
