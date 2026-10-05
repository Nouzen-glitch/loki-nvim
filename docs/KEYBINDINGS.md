# Keybindings

Custom bindings from `lua/config/keymaps.lua` and plugin configs. Leader is
**Space**. For the live, complete list (including built-ins and plugin
defaults) use `<leader>?`, `<leader>fk`, or the generated cheatsheet
(`<leader>fC` / `:Cheatsheet`). Your own bindings go in `lua/user/keymaps.lua`
([MIGRATING.md](MIGRATING.md)).

## Your own keys

They go in `lua/user/keymaps.lua` (`:LokiEdit keymaps` creates and opens it).
Give every mapping a `desc`: that is what shows in `<leader>?`, `<leader>fk` and
the generated cheatsheet (which covers normal, visual, operator-pending, insert,
terminal and command-line maps, plus buffer-local maps). This file lists only
the shipped keys.

- **Same key, yours wins** (this includes the LSP keys, which are attached per buffer but skip any key you set). It replaces the shipped one; the action can still be
  run as a command (`<leader>fc`) or moved to another key in the same file.
- **You are told.** `:LokiKeys` and `:checkhealth loki` list every shipped key
  you replaced, removed or shadowed, and Neovim shows a one-time notice at
  startup whenever that list changes.
- **Prefix delay.** If one of your keys is the start of a longer shipped key
  (yours `<leader>f`, shipped `<leader>ff`), or extends one, the *shorter* key
  waits `timeoutlen` (400 ms) to see whether you type more. Avoid prefixes.
- **Plugin keys can win.** `<C-\>` is set by toggleterm after your keymaps load;
  rebind it through toggleterm's `opts` ([MIGRATING.md](MIGRATING.md), section 4).
  Likewise `jk`, `<Esc>` and `<C-h/j/k/l>` in Terminal mode are set per toggleterm
  buffer, so a global Terminal-mode map of yours on those keys is shadowed there
  (and `:LokiKeys` does not report it). Other terminals are not affected.
- **Your own prefix labels.** `vim.g.loki_leader_groups = { g = "Git" }` in
  `lua/user/options.lua` names a new prefix in which-key and the cheatsheet.

Keys worth checking before you override them: `jk`, `<C-s>`, `<C-h/j/k/l>`,
`<C-d>`, `<C-u>`, `H`, `L`, `K`, `gd`, `gr`, `n`, `N`, `<Esc>`, `<C-\>`, and
anything starting with `<leader>f`, `<leader>w` or `<leader>c`.

## Fundamentals

| Key | Mode | Action |
| --- | --- | --- |
| `jk` | i, t | Leave Insert mode; leave Terminal mode in the toggleterm terminal (other terminals keep `jk` for the program) |
| Arrow keys | n, i, v | Disabled (`<Nop>`). Opt out: `vim.g.loki_disable_arrows = false` in `lua/user/options.lua` |
| `j` / `k` | n | Move by display line (wrapped lines); with a count (`5j`) by real lines |
| `n` / `N` | n | Next / previous search result, centered |
| `<` / `>` | v | Indent and keep selection |
| `<Esc>` | n | Clear search highlight |
| `<C-s>` | n | Save file |
| `<leader>q` | n | Quit window |
| `<C-d>` / `<C-u>` | n | Half page down / up, cursor centered |
| `J` / `K` | v | Move selected lines down / up |
| `p` | x | Paste over a selection without losing what you yanked |

## Windows and buffers

| Key | Action |
| --- | --- |
| `<C-h/j/k/l>` | Focus left / down / up / right window |
| `<leader>wv` / `<leader>ws` | Vertical / horizontal split |
| `<leader>wd` | Close window |
| `<leader>ww` | Cycle windows |
| `H` / `L` | Previous / next buffer (open buffers are shown along the top) |
| `<leader>bd` | Delete buffer |

`<C-h>` is also what some terminals send for Backspace. If Backspace switches
windows in Normal mode, remap Backspace in the terminal or move the window keys
in `lua/user/keymaps.lua`. Insert-mode `<C-h>` is deliberately not mapped.

## LSP

These keys exist **only in buffers where a language server is attached** (they
are set per buffer on `LspAttach`). Elsewhere they print a notice pointing at
`:LokiLsp`. A key you set yourself in `lua/user/keymaps.lua` is never replaced.
Details: [LSP.md](LSP.md).

| Key | Action |
| --- | --- |
| `K` | Hover documentation |
| `gd` `gD` `gi` `gr` | Definition / declaration / implementation / references |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action (n, v) |
| `<leader>ih` | Toggle inlay hints |
| `<leader>ci` / `<leader>co` | Call hierarchy: who calls this function / what it calls |
| `<C-s>` (insert) | Signature help (Neovim built-in) |

Neovim 0.11+ also provides defaults: `grn` rename, `gra` code action, `grr`
references, `gri` implementation, `grt` type definition, `gO` symbols,
`<C-s>` (insert/select) signature help.

Because `gr` is also mapped here, a lone `gr` waits `timeoutlen` (400 ms) in case
you are typing one of the longer defaults (`grr`, `gra`, `grn`, ...). `grr` works
at full speed.

## Diagnostics

| Key | Action |
| --- | --- |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>de` | Diagnostic float |
| `<leader>dq` | Send diagnostics to quickfix |
| `<leader>xx` | Trouble: all diagnostics |
| `<leader>xX` | Trouble: current buffer |
| `<leader>fd` | Diagnostics in Telescope |

## Find (Telescope)

| Key | Action |
| --- | --- |
| `<leader>ff` | Files |
| `<leader>fg` | Live grep (needs `rg`) |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fh` | Help tags |
| `<leader>fc` | Commands |
| `<leader>fk` | Keymaps |
| `<leader>fC` | Open generated cheatsheet |
| `<leader>fi` | Loki guide (`:LokiHelp`) |
| `<leader>fs` | Symbols in this file (needs a server) |
| `<leader>fS` | Symbols in the project (needs a server) |
| `<leader>fd` | Diagnostics of open files |
| `<leader>fG` | Changed files in git, with a diff preview |
| `<leader>fR` | Resume the last picker |
| `<leader>fw` | Search the word under the cursor in the project |
| `<leader>f/` | Fuzzy search lines in this file |
| `<leader>?` | which-key: all keybindings |

Keys inside Telescope, nvim-tree and Trouble are listed in [PLUGIN_KEYS.md](PLUGIN_KEYS.md).

## Explorer, formatting, git (see [GIT.md](GIT.md), [FILES.md](FILES.md))

| Key | Action |
| --- | --- |
| `<leader>e` | Toggle nvim-tree (`g?` inside for its help) |
| `<leader>E` | Reveal the current file in nvim-tree |
| `<leader>cf` | Format file / selection (n, v); also runs on save |
| `]h` / `[h` | Next / previous git hunk |
| `<leader>hs` | Stage hunk (Visual mode: only the selected lines) |
| `<leader>hr` | Reset hunk (Visual mode: only the selected lines) |
| `<leader>hu` | Undo the last stage |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame the cursor line |
| `<leader>hB` | Toggle blame text at the end of the line |
| `<leader>hd` | Diff the file against the index |

## Completion (insert mode, nvim-cmp)

| Key | Action |
| --- | --- |
| `<C-Space>` | Trigger completion |
| `<C-j>` / `<C-k>` | Next / previous item |
| `<Tab>` / `<S-Tab>` | Next / previous item, or jump in a snippet |
| `<CR>` | Accept selected item (nothing preselected) |
| `<C-e>` | Close menu |
| `<C-d>` / `<C-f>` | Scroll docs up / down |

Command-line (`:` and `/`) also has completion.

## Terminal (toggleterm)

| Key | Action |
| --- | --- |
| `<C-\>` | Toggle bottom terminal (works from every mode) |
| `<Esc>` or `jk` | Terminal mode to Normal mode (scroll, search) |
| `i` / `a` | Back to typing |
| `<C-h/j/k/l>` | Leave terminal to that window |

## Text objects and editing

`mini.ai` extends the `a`/`i` objects: after an operator (`d`, `c`, `y`, `v`)
type `i` (inside) or `a` (around) and a key: `(` `[` `{` `<` or `b` brackets,
`"` `'` `` ` `` or `q` quotes, `t` tag, `f` function call, `a` argument (`dia`,
`caq`, `yif`). The key popup lists them with descriptions. Function
*definitions* (`af`/`if` in other editors) are not available: they need the
`nvim-treesitter-textobjects` plugin. `mini.pairs` closes brackets and quotes as you type. Built-ins used
constantly: `ciw`, `ci"`, `ci(`, `da{`, `yiw`. `gcc` toggles a comment, `gc` +
motion/selection comments a range.

## Reading the key popup (which-key)
 
Press a key that starts a longer sequence (`<leader>`, `g`, `z`, `[`, `]`,
`<C-w>`, or an operator such as `d`, `y`, `c`) and wait a moment. A popup lists
what can follow, with a short description of each key.
 
- An entry that is a group (for example `Find` under `<leader>`) opens another
  list: type its next key to go deeper, or the final key to run the action.
- After an operator (`d`, `y`, `c`) the popup lists motions and text objects
  (`iw`, `i"`, `ap`, ...), so `d` then `i` shows what you can delete inside.
- `<BS>` goes up one level, `<Esc>` closes the popup, `<C-d>` / `<C-u>` scroll.
- `<leader>?` shows every key at once; `<leader>fk` searches keys by name.
- No popup? Run `:checkhealth which-key`.
 
## Leader namespaces

`f` Find (files, text, symbols, help), `w` Windows, `x` Trouble panels,
`h` Git (hunks, blame, diff), `b` Buffers, `c` Code (format, lint),
`d` Diagnostics and symbols, `i` Inlay hints, `r` Rename. Press `<leader>` and
wait for which-key.

Enabled [extras](EXTRAS.md) add `s` Session, `k` Clients, `t` Debug, `g` Git views, `m` Make / tasks and `n` Tests. They
exist only while the extra is enabled in `vim.g.loki_extras`.

## Extras keys

Declared only while the extra is enabled; see [EXTRAS.md](EXTRAS.md).

| Extra | Keys |
| --- | --- |
| sessions | `<leader>ss` restore this folder, `<leader>sl` restore the last session, `<leader>sd` do not save |
| dashboard | shortcut letters on the start screen (no global keys) |
| docker | `<leader>kk` lazydocker |
| database | `<leader>kd` database UI |
| rest | `<leader>kr` run the HTTP request under the cursor |
| dap | `<leader>tb` `<leader>tc` `<leader>tu` `<leader>tx`, `<F5>` `<F9>` `<F10>` `<F11>` `<S-F11>` |
| lint | `<leader>cl` lint now |
| surround | `gsa` add, `gsd` delete, `gsr` replace |
| diffview | `<leader>gd` diff view of all changes, `<leader>gh` history of this file, `<leader>gq` close |
| replace | `<leader>R` search and replace in the project |
| outline | `<leader>o` symbol outline |
| tasks | `<leader>mr` run a task, `<leader>mt` task list |
| test | `<leader>nn` nearest, `<leader>nf` file, `<leader>ns` explorer, `<leader>no` output, `<leader>nx` stop |
| ui | indent guides and sticky scroll (no keys) |
| history | `<leader>u` undo tree |

## Learning order

1. Insert/leave (`i a o`, `jk`), `hjkl`, `w b e`, `0 ^ $`, `dd yy p u <C-r>`
2. Operators plus text objects: `d c y` with `iw aw i" i( i{`
3. Navigation: `<leader>ff`, `<leader>fg`, `gd`, `gr`, `K`
4. Completion: `Tab`, `<C-Space>`, `<C-j/k>`, `<C-s>` for signatures
5. Refactoring: `<leader>rn`, `<leader>ca`, `gi`
6. Git hunks, Trouble, formatting, then anything advanced

Make each stage automatic before starting the next.
