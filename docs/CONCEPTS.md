# Vim concepts you will meet

Short explanations of the ideas that confuse people coming from other editors.

## Modes

Normal (move and command), Insert (type), Visual (select), Command-line (`:`),
Terminal. `jk` or `<Esc>` returns to Normal. Most keys in this documentation
are Normal-mode keys.

## Buffers, windows, tabs

- A **buffer** is a file loaded in memory. `H` / `L` cycle through them; the
  bar along the top lists them. `<leader>bd` removes one.
- A **window** is a view onto a buffer. `<leader>wv` / `<leader>ws` split,
  `<C-h/j/k/l>` move between them. Two windows can show the same buffer.
- A **tab page** is a layout of windows. Rarely needed; `:tabnew` makes one.

Closing a window does not close its buffer, and deleting a buffer does not
quit Neovim.

## Registers

Named clipboards. `"ayy` yanks a line into register `a`, `"ap` pastes it.
`clipboard=unnamedplus` makes the default register the system clipboard.
`"_d` deletes into the black hole (nothing is overwritten); the Visual `p` key
here does that for you. `:registers` lists them, and which-key lists them when
you press `"`.

## Marks

`ma` sets mark `a` in this file, `` `a `` jumps to it exactly, `'a` to its
line. Capital marks (`mA`) work across files. `` `` `` jumps back to where you
were. `<C-o>` / `<C-i>` walk the jump list (this is how you return after `gd`).

## Quickfix and location lists

A list of positions: search results, diagnostics, references. `gr`,
`<leader>dq` and Telescope's `<C-q>` fill the quickfix list. `:copen` shows it,
`:cnext` / `:cprev` walk it, `:cclose` closes it. The location list (`:lopen`)
is the same idea, one per window (`<leader>ds` uses it).

## Macros

`qa` starts recording into register `a`, do some edits, `q` stops. `@a` replays
it, `5@a` five times, `@@` repeats the last one. Plan the macro so it ends in
the right place for the next repeat (for example with `j0`).

## Folds

Hide blocks of text. Folds are manual by default: `zf` plus a motion creates
one (`zfap` folds a paragraph), `za` toggles, `zR` opens all, `zM` closes all.
For automatic folds from the syntax tree, set
`vim.g.loki_treesitter_folding = true` in `lua/user/options.lua`.

## Operators and text objects

`d`, `c`, `y` are operators; they wait for a motion or a text object.
`ciw` = change inner word, `da"` = delete a quoted string with its quotes,
`yi(` = yank inside parentheses. `i` means inside, `a` means around. The key
popup lists the objects after you type `d` then `i`.

## Counts and repeating

`3dd` deletes three lines; `.` repeats the last change; `u` undoes, `<C-r>`
redoes.

## Where next

[KEYBINDINGS.md](KEYBINDINGS.md), `:Tutor` (Neovim's own), `:LokiTutor`.
