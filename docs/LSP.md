# Code intelligence: LSP, diagnostics, formatting

## What it does

A **language server** reads your project and answers questions: where is this
defined, who uses it, what is its type, what is wrong with this line. Neovim
talks to it through its built-in LSP client; Mason installs the servers;
`nvim-cmp` shows the completions. Which servers run comes from the language
table ([ADDING_LANGUAGES.md](ADDING_LANGUAGES.md)).

## Keys

The LSP keys exist **only in buffers where a server is attached** (they are set
in an `LspAttach` autocmd, buffer-local). In any other buffer the same keys
print a short notice that points at `:LokiLsp`, instead of an error.

| Key | Action |
| --- | --- |
| `K` | Hover documentation (press again to enter the float) |
| `gd` / `gD` / `gi` | Definition / declaration / implementation |
| `gr` | References (quickfix list) |
| `<leader>D` | Type definition |
| `<leader>rn` | Rename everywhere |
| `<leader>ca` | Code action (quick fix, refactor) |
| `<leader>ds` | Symbols of this file (location list) |
| `<leader>fs` / `<leader>fS` | Symbols of this file / the project, in Telescope |
| `<leader>ih` | Toggle inlay hints |
| `<C-s>` (Insert) | Signature help |

Example: put the cursor on a function call, `gd` jumps to its definition, `<C-o>`
jumps back, `gr` lists every call, `<leader>rn` renames it in all files.

**Your own keys win.** If `lua/user/keymaps.lua` sets `gd` (or any key in the
table), the LSP attach step leaves your key alone, and `:LokiKeys` reports that
you replaced the shipped one.

## Diagnostics

Errors and warnings appear as virtual text, in the sign column and underlined.

| Key | Action |
| --- | --- |
| `]d` / `[d` | Next / previous diagnostic (opens its message) |
| `<leader>de` | Message at the cursor |
| `<leader>dq` | All diagnostics to the quickfix list |
| `<leader>xx` / `<leader>xX` | Trouble panel: all files / this buffer |
| `<leader>fd` | Diagnostics in Telescope |

## Formatting

`<leader>cf` formats the file or the selection with the formatter named in the
language table, or the language server when there is none. Saving formats too
(files over 200 KB are skipped). `:LokiFormat off` turns format on save off for
the session; to turn it off for good see [MIGRATING.md](MIGRATING.md), section 4.

## Linting

Optional: enable the `lint` extra ([EXTRAS.md](EXTRAS.md#lint)).

## `:LokiLsp`

One screen for the current buffer: attached servers and roots, formatter,
tree-sitter state, the language-table entry, and the most likely reason when
nothing is attached.

## Common failures

| Symptom | Cause and fix |
| --- | --- |
| Key prints "needs a language server" | None attached. `:LokiLsp` names the reason |
| Server not installed | `:Mason`; `:MasonLog` shows the error; install Node.js / Python 3 / Go as needed |
| Installed but not attached | File outside a project root (needs `.git` or a project file), or the filetype is not in the language table |
| `K` or `gd` does something else | You mapped it yourself (`:LokiKeys`), or the buffer has no server |
| Rename misses files | Only files the server knows about; open the project root |
| No completion | `:checkhealth vim.lsp`; see [COMPLETION.md](COMPLETION.md) |

## Where next

[ADDING_LANGUAGES.md](ADDING_LANGUAGES.md), [COMPLETION.md](COMPLETION.md),
[TROUBLESHOOTING.md](TROUBLESHOOTING.md), `:LokiHelp lsp`.
