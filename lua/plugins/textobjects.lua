-- Text objects (mini.ai), auto-pairs (mini.pairs) and the key popup (which-key).
--
-- The popup content comes from three places, all descriptive:
--   * every shipped key's `desc` (util/registry.lua), through the mapping itself
--   * leader group labels (config/leader_groups.lua)
--   * this file: labels for keys that are not mappings (the ] and [ prefixes,
--     mini.ai's a/i objects), so they are listed with a description too.

-- mini.ai default objects (kept in one table so mini.ai and which-key agree).
-- Function DEFINITIONS (af/if in other editors) would need nvim-treesitter-textobjects
-- queries; mini.ai's `f` here is a function CALL.
local objects = {
    { "(", "parentheses ( )" },
    { "[", "square brackets [ ]" },
    { "{", "curly braces { }" },
    { "<", "angle brackets < >" },
    { "b", "any brackets ( ) [ ] { }" },
    { '"', "double quotes" },
    { "'", "single quotes" },
    { "`", "backticks" },
    { "q", "any quotes" },
    { "t", "HTML/XML tag" },
    { "f", "function call: name(args)" },
    { "a", "argument of a call or definition" },
    { "?", "custom: prompts for the surrounding characters" },
}

local function object_spec()
    local spec = {
        { "i", group = "inside…", mode = { "o", "x" } },
        { "a", group = "around…", mode = { "o", "x" } },
    }
    for _, o in ipairs(objects) do
        table.insert(spec, { "i" .. o[1], desc = "inside " .. o[2], mode = { "o", "x" } })
        table.insert(spec, { "a" .. o[1], desc = "around " .. o[2], mode = { "o", "x" } })
    end
    return spec
end

-- Neovim's own ] and [ motions, labeled so the popup says what happens.
local function bracket_spec()
    return {
        { "]", group = "Next…" },
        { "[", group = "Previous…" },
        { "]]", desc = "Next section / function start" },
        { "[[", desc = "Previous section / function start" },
        { "][", desc = "Next section end" },
        { "[]", desc = "Previous section end" },
        { "]m", desc = "Next method start" },
        { "[m", desc = "Previous method start" },
        { "]s", desc = "Next misspelled word" },
        { "[s", desc = "Previous misspelled word" },
        { "]p", desc = "Paste below, adjusting indent" },
        { "[p", desc = "Paste above, adjusting indent" },
        { "]c", desc = "Next diff change (or next git change in the tree)" },
        { "[c", desc = "Previous diff change" },
        { "]'", desc = "Next lowercase mark line" },
        { "['", desc = "Previous lowercase mark line" },
        -- Neovim 0.11 LSP defaults (see docs/KEYBINDINGS.md, section LSP)
        { "grn", desc = "Rename symbol (Neovim default)" },
        { "gra", desc = "Code action (Neovim default)", mode = { "n", "x" } },
        { "grr", desc = "References (Neovim default)" },
        { "gri", desc = "Implementation (Neovim default)" },
        { "grt", desc = "Type definition (Neovim default)" },
        { "gO", desc = "Outline: symbols of this file (Neovim default)" },
    }
end

return {
    {
        "echasnovski/mini.ai",
        event = "VeryLazy",
        opts = {},
    },

    {
        -- Auto-close brackets and quotes.
        "echasnovski/mini.pairs",
        event = "InsertEnter",
        opts = {},
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = function()
            local spec = require("config.leader_groups").which_key_spec()
            vim.list_extend(spec, bracket_spec())
            vim.list_extend(spec, object_spec())
            return { spec = spec }
        end,
    },
}
