return {
    {
        "nvim-treesitter/nvim-treesitter",
        -- Upstream's `main` branch is an incompatible rewrite that needs Neovim 0.12 and
        -- the tree-sitter CLI; `master` is locked and kept for Neovim 0.11.
        -- Migration plan: docs/TREESITTER_MIGRATION.md.
        branch = "master",
        lazy = false,
        build = ":TSUpdate",
        -- Neovim 0.12 passes query predicates a LIST of nodes per capture; the `master`
        -- branch still expects a single node, so its indent (and a few other queries)
        -- fail with "attempt to call method 'type' (a nil value)": Enter inside {}
        -- leaves the cursor and the closing bracket at column 0. Hand its handlers the
        -- last node of each list. Only handlers registered by nvim-treesitter's own
        -- query_predicates.lua are wrapped; remove this when moving to `main`
        -- (docs/TREESITTER_MIGRATION.md).
        init = function()
            if vim.fn.has("nvim-0.12") == 0 then
                return
            end
            local query = vim.treesitter.query
            local function single_node(handler)
                return function(match, ...)
                    local view = setmetatable({}, {
                        __index = function(_, id)
                            local nodes = match[id]
                            if type(nodes) == "table" then
                                return nodes[#nodes]
                            end
                            return nodes
                        end,
                    })
                    return handler(view, ...)
                end
            end
            local function wrap(register)
                return function(name, handler, opts)
                    local src = debug.getinfo(2, "S").source
                    if src:find("nvim-treesitter", 1, true) and src:find("query_predicates.lua", 1, true) then
                        handler = single_node(handler)
                    end
                    return register(name, handler, opts)
                end
            end
            query.add_predicate = wrap(query.add_predicate)
            query.add_directive = wrap(query.add_directive)
        end,
        config = function()
            -- Parsers come from config/languages.lua (+ languages_local.lua),
            -- plus the ones the enabled extras need (sql, http, dockerfile).
            local parsers = require("util.languages").parsers()
            local extras = require("util.extras")
            for _, name in ipairs(extras.enabled()) do
                vim.list_extend(parsers, extras.registry[name].parsers or {})
            end
            require("nvim-treesitter.configs").setup({
                ensure_installed = parsers,
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
                -- Fetch a parser on demand when you open an unlisted filetype
                -- (highlighting only, no LSP). Set to false to install only listed parsers.
                auto_install = true,
            })
        end,
    },

    {
        -- Brackets coloured by nesting depth (like VS Code's bracket pair colorization).
        -- Needs no setup; it uses the tree-sitter parsers above.
        -- Turn off: vim.g.loki_rainbow_brackets = false in lua/user/options.lua.
        "HiPhish/rainbow-delimiters.nvim",
        enabled = function()
            return vim.g.loki_rainbow_brackets ~= false
        end,
        -- Its only submodule is for its own test suite (hosted on GitLab); skip it.
        submodules = false,
        event = { "BufReadPost", "BufNewFile" },
    },
}
