-- Every shipped key is declared in lua/util/registry.lua (description, long help,
-- example, doc link) and created here. To change a key for yourself, use
-- lua/user/keymaps.lua (loaded after this file). To add a shipped key, add an
-- entry to the registry: scripts/check-help.sh fails until it is documented.
--
-- Keys are created with vim.keymap.set so util/keyguard.lua can track them.
-- LSP keys (K, gd, gr, ...) are created per buffer when a server attaches
-- (util/lsp.lua); the entries here are the friendly "no server attached" notice.
local registry = require("util.registry")

for _, entry in ipairs(registry.shipped_keys()) do
    registry.apply(entry)
end

-- Signature help in Insert mode is Neovim's built-in <C-s> (0.11+). A custom
-- <C-h> mapping is avoided because many terminals send <C-h> for Backspace.
--
-- Terminal-mode keys (jk, <Esc>, <C-h/j/k/l>) are set in plugins/terminal.lua,
-- for toggleterm buffers only, so they never get in the way of TUIs.
