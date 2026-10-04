# Plan: nvim-treesitter `master` to `main`

**Status: planned, not done.** The config is pinned to the `master` branch. Do
not start without a decision.

## Why it matters

The upstream README says `main` is "a full, incompatible, rewrite" and that
`master` is "locked", kept only for backward compatibility with Neovim 0.11.
`main` requires **Neovim 0.12.0 or later**, `tar`, `curl`, a C compiler and the
`tree-sitter` CLI (0.26.1 or later, from a package manager, not npm), and it
does not support lazy-loading. So `master` will receive no new parsers or fixes.

## What changes in this repo

| Area | Today (`master`) | After (`main`) |
| --- | --- | --- |
| Setup call | `require("nvim-treesitter.configs").setup{...}` | `require("nvim-treesitter").setup{ install_dir = ... }`; that module no longer exists |
| Parsers | `ensure_installed`, `auto_install = true` | `require("nvim-treesitter").install({ ... })` explicitly; no `auto_install` |
| Highlight and indent | `highlight.enable`, `indent.enable` | Enable per filetype yourself: `vim.treesitter.start()` in a `FileType` autocmd, `indentexpr` for indent |
| Requirements | C compiler | plus `tree-sitter` CLI and Neovim 0.12 |
| Lockfile | branch `master` | branch `main`, and parsers need `:TSUpdate` |

Files to touch: `lua/plugins/treesitter.lua`, `lua/util/languages.lua` (parser
list is reused), `lua/loki/health.lua` (check for the
`tree-sitter` CLI and Neovim 0.12), `scripts/install.sh` (requirement check),
`docs/README.md`, `docs/INSTALL.md`, `docs/ENVIRONMENT_GUIDE.md` (gotchas row),
`docs/COMPONENTS.md`, `lazy-lock.json`, `CHANGELOG.md` (upgrade notes).

## Steps

1. Decide to require Neovim 0.12 (today the minimum is 0.11).
2. Branch the work; change the spec to `branch = "main"`.
3. Port the `config` function to the new API. Keep `util.languages.parsers()`
   as the source and add the extras' parsers as today.
4. Add a `FileType` autocmd that starts highlighting and sets `indentexpr`,
   skipping filetypes without an installed parser.
5. Add `tree-sitter` to the health check and the installer warnings.
6. Test: fresh `install.sh --alongside`; open a file of each language; `:InspectTree`;
   `:checkhealth nvim-treesitter`; the opt-in folding switch.
7. Update docs and the CHANGELOG upgrade notes ("run `:TSUpdate`, install the
   `tree-sitter` CLI").

## Rollback

Keep `branch = "master"` in the spec and restore the old lockfile entry.
