# Loki Neovim versus VS Code

Written 2026-10-05. An honest comparison: what already matches, what was missing
and has now been added, and what is still missing on purpose.

## Short answer

The editing core was already on par: LSP, completion, diagnostics, fuzzy finding,
formatting, git hunks, a terminal, debugging (extra), sessions (extra). What kept
it from replacing VS Code for everyday programming was the layer around that
core: source-control views, project-wide replace, an outline, tasks, a test
explorer, schema-aware JSON/YAML, and the small visual defaults people notice
immediately (indent guides, sticky scroll). Those are now covered, as opt-in
extras so the default behaviour does not change. The gaps that remain are mostly
ecosystem ones (AI assistant, remote development, notebooks, native Windows), not
editor ones.

## Gap analysis

| VS Code feature | Before | Now |
| --- | --- | --- |
| Source Control: diff of all changes, file timeline, merge editor | Only single hunks (gitsigns) | `diffview` extra: `<leader>gd` `gh` `gq` |
| Search and replace across the project | Search only (`<leader>fg`) | `replace` extra: `<leader>R` |
| Outline view | Symbols picker only | `outline` extra: `<leader>o` |
| Tasks (`tasks.json`, npm scripts, make) | None; use the terminal | `tasks` extra: `<leader>mr` `mt` |
| Testing view | None | `test` extra (pytest, jest): `<leader>nn` `nf` `ns` `no` `nx` |
| JSON / YAML validation and completion from schemas | No language server for them | `jsonls` + `yamlls` with SchemaStore, on by default |
| HTML, CSS, TOML, Dockerfile support | Opt-in only | Default languages |
| Indent guides, sticky scroll | None | `ui` extra |
| Timeline / local history | Persistent undo, no view | `history` extra: `<leader>u` |
| Call hierarchy | None | `<leader>ci` / `<leader>co` |
| Search in file, word under cursor, reopen last search | Missing | `<leader>f/`, `<leader>fw`, `<leader>fR` |
| CI that keeps keys, docs and help in sync | Manual scripts only | `.github/workflows/ci.yml` (Neovim 0.11 and stable) |

## Still missing (not changed in this pass)

| Gap | Why it was left |
| --- | --- |
| AI assistant and inline completions (Copilot-style) | Needs a vendor decision, and keys must come from the environment; see the note in [EXTRAS.md](EXTRAS.md) |
| Remote development (SSH, containers, WSL as a workspace) | No equivalent plugin worth shipping; running Neovim inside `tmux` over SSH is the usual answer |
| Native Windows installer, tested macOS support | WSL 2 is the supported Windows route; macOS is untested and the scripts use GNU tools |
| Function text objects (`af` / `if`) | Open item 1 in `HANDOFF.md`; needs `nvim-treesitter-textobjects` and ties into the tree-sitter `main` migration |
| Multi-cursor (Ctrl+D) | Vim covers it with `*` then `cgn`, `:s` and Visual-block; a plugin would fight the key scheme |
| Notebooks, Live Share, minimap, extension marketplace, settings UI | Different product category; extra plugins go in `lua/user/plugins/` |
| Tree-sitter `master` to `main` | Plan only ([TREESITTER_MIGRATION.md](TREESITTER_MIGRATION.md)); needs Neovim 0.12 |

## How this was checked

On Neovim 0.11.4, headless, with every new extra enabled and the plugins
installed from GitHub:

- `scripts/check-help.sh` passes (keys, commands, docs, `doc/loki.txt`).
- Each new key is mapped, and each plugin loads and its commands run
  (`DiffviewOpen`, `GrugFar`, `AerialToggle`, `OverseerToggle`, neotest summary,
  `UndotreeToggle`, SchemaStore schemas).
- Found and fixed during testing: the `grug-far.nvim` owner was wrong, and
  aerial's `master` branch requires Neovim 0.12, so it is pinned to its
  `nvim-0.11` branch.
- The new plugins have real commits in `lazy-lock.json`.

**Not verified**

- Mason installing the new language servers: the sandbox proxy blocked the
  Mason registry, so only the configuration was checked, not the downloads.
- Anything interactive (the look of the diff view, outline, indent guides) and
  Neovim 0.12.
- The CI workflow itself, which only runs on GitHub.

Adopt the new plugin versions with `:LokiLockReset`, restart, then `:Lazy restore`.
