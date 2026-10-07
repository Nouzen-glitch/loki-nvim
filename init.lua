-- Neovim "Loki IDE" configuration
-- See docs/README.md for installation, rationale, and keybinding reference.
--
-- Your own changes go in lua/user/ (gitignored); see docs/MIGRATING.md.

local user = require("util.user")
local keyguard = require("util.keyguard")

require("config.options")
user.load("user.options")
-- keyguard watches vim.keymap.set while these two files load, so it can tell
-- you which shipped keys your own keymaps replace (:LokiKeys).
keyguard.track_shipped(function()
    require("config.keymaps")
    require("util.extras").keymaps() -- keys of enabled extras, tracked like shipped keys
end)
keyguard.track_user(function()
    user.load("user.keymaps")
end)
require("config.autocmds")
require("config.lazy")
require("util.cheatsheet").setup()
require("util.lockfile").setup()
require("util.welcome").setup()
require("util.guide").setup()
require("util.extras").setup()
keyguard.setup()
