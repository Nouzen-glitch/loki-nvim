# Using an AI assistant

Loki does not bundle an assistant: the vendor is your choice. Three routes,
from least to most setup.

## 1. The terminal route (no code, any assistant with a CLI)

Run the assistant's command-line tool in the integrated terminal:

1. `<C-\>` toggles the bottom terminal (`2<C-\>` a second one).
2. Start the tool there (for example `claude`, or whatever your vendor ships).
3. `jk` or `<Esc>` leaves Terminal mode to scroll; `<C-\>` hides it.

Or run Neovim inside `tmux` or `zellij` and keep the assistant in another pane.
Both work with every extra and need no Neovim configuration.

## 2. The `ai` extra (one key, a side terminal)

Enable it and name the command in `lua/user/options.lua`:

```lua
vim.g.loki_extras = { "ai" }
vim.g.loki_ai_cmd = "claude"        -- any command, arguments allowed
```

| Key | Action |
| --- | --- |
| `<leader>aa` | Toggle the assistant in a terminal on the right |

The terminal keeps running while hidden. Inside it `jk` and `<Esc>` belong to
the program (assistants use Escape), so leave with `<C-h>` (to the window on
the left); come back with `<leader>aa`. `:checkhealth loki` warns when
`vim.g.loki_ai_cmd` is unset or the program is not on `PATH`.

## 3. In-editor plugins (inline edits, chat buffers)

Add one from `lua/user/plugins/` (see [MIGRATING.md](MIGRATING.md), section 4).
Candidates include `claudecode.nvim`, `codecompanion.nvim` and Copilot's plugins.
Their names and setup were not checked for this guide: read each README first.

## Keys and secrets

API keys come from environment variables only. Do not write them in
`lua/user/`: `scripts/user-layer.sh export`, `:LokiBackup` and the safety copies
pack that folder, so a key there ends up in every archive.

## Where next

[EXTRAS.md](EXTRAS.md#ai), [TERMINAL.md](TERMINAL.md), [REMOTE.md](REMOTE.md).
