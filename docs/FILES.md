# The file explorer

## What it does

`nvim-tree` is the sidebar for browsing and changing files. `nvim .` (or
`nvim some/folder`) opens it for that folder.

## Keys

| Key | Action |
| --- | --- |
| `<leader>e` | Toggle the explorer |
| `<leader>E` | Reveal the current file in it |

Inside the tree press **`g?`** for the full list. The ones you need first:

| Key | Action |
| --- | --- |
| `<CR>` / `o` | Open the file, or expand the folder |
| `a` | Create a file (end the name with `/` for a folder) |
| `r` / `e` | Rename / rename without the extension |
| `d` | Delete (asks first) |
| `c` / `x` / `p` | Copy / cut / paste |
| `<C-v>` / `<C-x>` / `<C-t>` | Open in a vertical split / horizontal split / tab |
| `H` | Show or hide dotfiles |
| `R` | Refresh |
| `q` | Close |

Example: `<leader>e`, move to a folder, `a`, type `notes.md`, Enter creates it.

## Common failures

| Symptom | Cause and fix |
| --- | --- |
| `nvim .` shows an empty buffer | The explorer opens for a single folder argument only |
| New files do not show | `R` refreshes |
| `H` hides or shows too much | Dotfiles are shown by default here; `H` toggles |
| Icons are boxes | Nerd Font |

## Where next

[PLUGIN_KEYS.md](PLUGIN_KEYS.md#nvim-tree), [FINDING.md](FINDING.md), `:LokiHelp files`.
