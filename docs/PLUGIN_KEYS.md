# Keys inside plugin windows

These keys belong to the plugins, not to this config. Each window can show its
own list: nvim-tree `g?`, Telescope `?` (Normal) or `<C-/>` (Insert), Trouble
`?`. Verified against the plugin versions in `lazy-lock.json`.

## Telescope

| Key | Action |
| --- | --- |
| `<C-j>` / `<C-k>` (also `<C-n>` / `<C-p>`) | Next / previous result |
| `<CR>` | Open |
| `<C-x>` / `<C-v>` / `<C-t>` | Open in a horizontal split / vertical split / tab |
| `<C-q>` | Send all results to the quickfix list and open it |
| `<M-q>` | Send only the selected (Tab-marked) results |
| `<Tab>` / `<S-Tab>` | Mark a result and move |
| `<C-/>` (Insert) or `?` (Normal) | Show every key of this picker |
| `<Esc>` (Normal) / `<C-c>` | Close |

## nvim-tree

Press `g?` in the tree for the full list. Common keys: `a` create, `r` rename,
`d` delete, `c` `x` `p` copy / cut / paste, `<CR>` or `o` open, `<C-v>` `<C-x>`
`<C-t>` open in a split or tab, `H` dotfiles, `I` git-ignored files, `R`
refresh, `E` expand all, `W` collapse all, `f` live filter, `-` go up a folder,
`q` close.

## Trouble

Opened with `<leader>xx` or `<leader>xX`. Press `?` in the panel for its list.

| Key | Action |
| --- | --- |
| `<CR>` | Jump to the item |
| `o` | Jump and close the panel |
| `<C-s>` / `<C-v>` | Jump in a horizontal / vertical split |
| `}` / `{` (also `]]` / `[[`) | Next / previous item |
| `p` / `P` | Preview / toggle preview |
| `r` | Refresh |
| `q` | Close |

## toggleterm

`<C-\>` toggles the bottom terminal; `2<C-\>` toggles terminal 2 (and so on);
`:TermSelect` lists terminals; `:ToggleTermToggleAll` shows or hides them all.
In the terminal, `jk` or `<Esc>` leaves Terminal mode.

## gitsigns

The shipped keys are in [GIT.md](GIT.md). Everything else is a command with
completion: type `:Gitsigns ` and press `<Tab>`. Useful ones:
`:Gitsigns toggle_deleted` (show removed lines), `:Gitsigns blame` (blame the
whole file), `:Gitsigns diffthis ~` (diff against the last commit).

## nvim-cmp and LuaSnip

See [COMPLETION.md](COMPLETION.md). `<Tab>` and `<S-Tab>` choose menu items or
jump between snippet fields.

## which-key popup

`<BS>` up one level, `<Esc>` close, `<C-d>` / `<C-u>` scroll the popup.
