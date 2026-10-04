# Completion and snippets

## What it does

`nvim-cmp` shows a menu while you type, fed by the language server, snippets
(LuaSnip with friendly-snippets), file paths and words from the buffer. Nothing
is preselected, so Enter never inserts something you did not choose.

## Keys (Insert mode)

| Key | Action |
| --- | --- |
| `<C-Space>` | Open the menu |
| `<C-j>` / `<C-k>` | Next / previous item |
| `<Tab>` / `<S-Tab>` | Next / previous item; inside a snippet, next / previous field |
| `<CR>` | Accept the selected item |
| `<C-e>` | Close the menu |
| `<C-d>` / `<C-f>` | Scroll the documentation window up / down |
| `<C-s>` | Signature help (Neovim built-in) |

Command-line completion also works for `:` and `/`.

## Snippets

Accept a snippet item (for example `fn` in a Rust file, or `for` in Lua) with
Enter. The cursor lands on the first field; `<Tab>` jumps to the next field,
`<S-Tab>` back. Without a snippet active, `<Tab>` inserts a Tab. Snippets come
from friendly-snippets and depend on the filetype.

## Common failures

| Symptom | Cause and fix |
| --- | --- |
| No menu at all | `:Lazy` shows whether nvim-cmp loaded; it loads on the first Insert |
| Menu has words but no code items | No language server attached: `:LokiLsp` |
| `<Tab>` inserts a Tab | No menu is open and no snippet is active; use `<C-Space>` |
| `:` completion missing until Insert | Keep `CmdlineEnter` in the cmp spec ([ENVIRONMENT_GUIDE.md](ENVIRONMENT_GUIDE.md), section 8) |
| `<C-j>` does nothing in a terminal | Some terminals send `<C-j>` as Enter |

## Where next

[LSP.md](LSP.md), [PLUGIN_KEYS.md](PLUGIN_KEYS.md), `:LokiHelp lsp`.
