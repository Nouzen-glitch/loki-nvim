# Handoff notes for the next maintainer (human or AI)

Written 2026-10-04, after the second review pass. Read this before changing anything.

## How this repo works (the rules that bite)

- `lua/util/registry.lua` is the single source of truth for every shipped key, command and help topic.
  After changing it run `scripts/gen-help.sh` (rewrites `doc/loki.txt`), then `scripts/check-help.sh`,
  then `scripts/smoke-test.sh`. `doc/loki.txt` is generated: never edit it by hand, commit the regenerated file.
- Every key needs `desc`, `long`, `group`, `see`, and a mention in `docs/KEYBINDINGS.md`. Every docs file must be linked from `docs/README.md`.
- `lua/user/*` and `lua/config/languages_local.lua` are the user's gitignored layer. Never commit them, never delete them, never test with a real one left behind.
- Do not edit shipped files to customize behaviour for one user; that blocks `scripts/update.sh`. Use `lua/user/`.
- `vim.keymap.set` / `vim.keymap.del` are wrapped while keymap files load (`util/keyguard.lua`). Keys set later or through `nvim_set_keymap` are not tracked.
- `docs/ENVIRONMENT_GUIDE.md` section 8 lists the gotchas; read it before touching lsp, terminal, extras or the lockfile.

## State after this pass

Fixed (patch `loki-fixes.patch`, from reading the code, not run in a real Neovim):

1. Visual `p` used `"_dP`, which pastes one character too early when the selection ends at the end of a line. Now Visual `P`.
2. `util/helpdoc.lua` `wrap()` collapsed indentation, breaking code examples in `:LokiHelp` and `doc/loki.txt`. Lines starting with whitespace are now kept as written, and the `languages` intro was split so its example is an indented line.
3. `scripts/user-layer.sh import` now rejects archives containing symlinks, hard links or special files.
4. `extras/lint.lua` no longer calls the private `lint._resolve_linter_by_ft`.
5. `util/welcome.lua` uses extmarks instead of the deprecated `nvim_buf_add_highlight`.

MUST DO after applying the patch: run `scripts/gen-help.sh` and commit the new `doc/loki.txt`. The patch changes help text, so `check-help.sh` fails until it is regenerated.

## Not verified

- Neovim 0.12 (docs say the maintainer runs 0.12.x; earlier testing was on 0.11.4). Run `smoke-test.sh`, `check-help.sh`, `:checkhealth loki` and look for deprecation warnings.
- The patch itself: hunks were checked with `git apply --check` against excerpts only, and the wrap and tar logic were tested in isolation. No Neovim was available. Run the three scripts above after applying.
- `:LokiDocs` picker, tree-sitter folding (`vim.g.loki_treesitter_folding`), Windows, macOS.

## Open issues, in suggested order

1. `af`/`if` function text objects: add `nvim-treesitter-textobjects` on branch `master`, registry entries (`set = false`), docs rows, lockfile entry. Redo on `main` during the migration.
2. Docs-only keys (completion, terminal, `gs*`) are only checked against the docs, not against what plugins really bind. Add a smoke check using `vim.fn.maparg` after the plugins load.
3. `:LokiEdit plugins` copies an example that returns only comments (an empty spec). Check lazy.nvim does not complain; `config/lazy.lua` notes it errors on an import with no specs.
4. `lua_ls` is deliberately scoped to the config folder (`plugins/lsp.lua`); a user override via `lua/user/options.lua` is unreliable. Consider an official hook.
5. `<C-h>` moves windows; terminals that send Backspace as `^H` will trigger it (documented, not changed).
6. Treesitter `master` to `main`: plan only, `docs/TREESITTER_MIGRATION.md`. Needs Neovim 0.12 and the `tree-sitter` CLI. Do not start without a decision.
7. Installs under the old `elite` app name must reinstall as `loki` (see CHANGELOG upgrade notes).
