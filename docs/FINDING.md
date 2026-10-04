# Finding things

## What it does

Telescope is a fuzzy finder: it opens a list, filters it as you type and
previews the result. Everything under `<leader>f` uses it. You never need to
memorise keys: `<leader>?` lists them, `<leader>fk` searches them.

## Keys

| Key | Action |
| --- | --- |
| `<leader>ff` | Files by name |
| `<leader>fg` | Text in the project (needs `ripgrep`) |
| `<leader>fb` | Open buffers |
| `<leader>fr` | Recent files |
| `<leader>fs` / `<leader>fS` | Symbols in this file / in the project (needs a server) |
| `<leader>fd` | Diagnostics of open files |
| `<leader>fG` | Changed files in git |
| `<leader>fh` | Neovim help (type `loki` for these pages) |
| `<leader>fc` | Commands |
| `<leader>fk` | Keymaps |
| `<leader>fC` | The generated cheatsheet |
| `<leader>fi` | The Loki guide (`:LokiHelp`) |
| `<leader>?` | Every global key (which-key) |

Inside a picker see [PLUGIN_KEYS.md](PLUGIN_KEYS.md#telescope): `<C-j>`/`<C-k>`
move, Enter opens, `<C-x>`/`<C-v>` open in a split, `<C-q>` sends the results
to the quickfix list, `?` or `<C-/>` lists every picker key.

Example: `<leader>fg`, type `TODO`, move with `<C-j>`, Enter jumps there;
`<C-q>` instead collects every match in the quickfix list.

## The key popup (which-key)

Press `<leader>`, `g`, `z`, `[`, `]`, `<C-w>` or an operator (`d`, `y`, `c`) and
wait. A popup lists what can follow with a description of each key. After an
operator, type `i` or `a` to see the text objects (quotes, brackets, arguments,
function calls). `<BS>` goes up a level, `<Esc>` closes. No popup:
`:checkhealth which-key`.

## Common failures

| Symptom | Cause and fix |
| --- | --- |
| `<leader>fg` does nothing | Install `ripgrep` (`rg`) |
| Files you expect are missing | Telescope hides git-ignored files; search from the project root |
| Icons are boxes | Use a Nerd Font in the terminal |
| Symbols picker is empty | No language server attached: `:LokiLsp` |

## Where next

[FILES.md](FILES.md), [CONCEPTS.md](CONCEPTS.md), `:LokiHelp files`.
