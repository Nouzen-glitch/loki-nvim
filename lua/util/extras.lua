-- Opt-in "extras": heavier features that are off by default.
--
-- Enable them in lua/user/options.lua (read before lazy.nvim starts):
--   vim.g.loki_extras = { "sessions", "dashboard" }
--
-- Each extra is described in M.registry:
--   desc     one line for :LokiExtras
--   plugins  true if lua/extras/<name>.lua exists (a lazy.nvim spec, imported
--            by config/lazy.lua only when the extra is enabled)
--   groups   <leader> prefixes it adds (feeds which-key and the cheatsheet)
--   keys     (none here) the keys of an extra live in util/registry.lua with
--            `extra = "<name>"`; M.keymaps() creates them while the extra is enabled
--   plugin_keys  keys the plugin itself creates late (listed so util/keyguard can
--            warn when your keymaps clash): { { modes = {...}, lhs = "...", desc = "..." } }
--   setup    optional function run once at startup (commands)
--   health   optional function(ctx) for :checkhealth loki
-- Nothing here loads a plugin; disabled extras cost nothing.
local M = {}

local function has(name)
    return vim.fn.executable(name) == 1
end

M.order = { "sessions", "dashboard", "docker", "database", "rest", "dap", "lint", "surround" }

M.registry = {
    sessions = {
        desc = "Restore the files and splits you had open in a folder (persistence.nvim)",
        plugins = true,
        groups = { { key = "s", label = "Session" } },
    },

    dashboard = {
        desc = "Start screen with recent files and shortcuts (alpha-nvim)",
        plugins = true,
    },

    docker = {
        desc = "lazydocker in a floating terminal (no plugin; needs docker and lazydocker)",
        plugins = false,
        parsers = { "dockerfile" },
        groups = { { key = "k", label = "Clients" } },
        health = function(c)
            c.check_tool("docker", c.h.warn, "Needed by the docker extra.")
            c.check_tool("lazydocker", c.h.warn, "The docker extra opens it. Install: https://github.com/jesseduffield/lazydocker")
        end,
    },

    database = {
        desc = "Database UI and SQL completion (vim-dadbod, vim-dadbod-ui)",
        plugins = true,
        parsers = { "sql" },
        groups = { { key = "k", label = "Clients" } },
        health = function(c)
            for _, tool in ipairs({ "psql", "mysql", "sqlite3" }) do
                if has(tool) then
                    c.h.ok(tool .. " found")
                end
            end
            c.h.info("vim-dadbod needs the CLI client of each database you connect to (psql, mysql, sqlite3, ...).")
        end,
    },

    rest = {
        desc = "Run requests from .http files with curl (built in, no plugin)",
        plugins = false,
        parsers = { "http" },
        groups = { { key = "k", label = "Clients" } },
        setup = function()
            vim.api.nvim_create_user_command("LokiRest", function()
                require("util.rest").run()
            end, { desc = require("util.registry").command_desc("LokiRest") })
        end,
        health = function(c)
            c.check_tool("curl", c.h.warn, "The rest extra sends requests with curl.")
        end,
    },

    dap = {
        desc = "Debugging: breakpoints, stepping, variables UI (nvim-dap, nvim-dap-ui)",
        plugins = true,
        groups = { { key = "t", label = "Debug" } },
        health = function(c)
            c.check_tool("python3", c.h.warn, "debugpy (Python debugging) is installed with Python 3 and venv.")
            c.check_tool("node", c.h.warn, "js-debug-adapter (JavaScript/TypeScript debugging) needs Node.js.")
            c.h.info("Adapters (debugpy, codelldb, js-debug-adapter) are installed by Mason; see :Mason.")
        end,
    },

    lint = {
        desc = "Linting on save with nvim-lint (the language table's `linter` field)",
        plugins = true,
        health = function(c)
            local langs = require("util.languages")
            local seen = {}
            for _, names in pairs(langs.linters_by_ft()) do
                for _, name in ipairs(names) do
                    if not seen[name] then
                        seen[name] = true
                        c.check_tool(name, c.h.warn, "Linter for the lint extra. Install it with :Mason (package names can differ).")
                    end
                end
            end
        end,
    },

    surround = {
        desc = "Add, delete and replace surrounding quotes and brackets (mini.surround, keys gsa gsd gsr)",
        plugins = true,
        plugin_keys = {
            { modes = { "n", "x" }, lhs = "gsa", desc = "Surround: add (mini.surround)" },
            { modes = { "n" }, lhs = "gsd", desc = "Surround: delete (mini.surround)" },
            { modes = { "n" }, lhs = "gsr", desc = "Surround: replace (mini.surround)" },
        },
    },
}

-- Names from vim.g.loki_extras: { valid names in the order given }, { unknown names }.
function M.requested()
    local want = vim.g.loki_extras
    if type(want) == "string" then
        want = { want }
    end
    local ok, bad, seen = {}, {}, {}
    if type(want) ~= "table" then
        return ok, bad
    end
    for _, name in ipairs(want) do
        if not seen[name] then
            seen[name] = true
            table.insert(M.registry[name] and ok or bad, tostring(name))
        end
    end
    return ok, bad
end

function M.enabled()
    return (M.requested())
end

function M.is_enabled(name)
    return vim.tbl_contains(M.enabled(), name)
end

-- Leader groups of the enabled extras, one entry per key.
function M.groups()
    local out, seen = {}, {}
    for _, name in ipairs(M.enabled()) do
        for _, g in ipairs(M.registry[name].groups or {}) do
            if not seen[g.key] then
                seen[g.key] = true
                table.insert(out, vim.deepcopy(g))
            end
        end
    end
    return out
end

-- Shipped keys of the enabled extras. Called from init.lua inside
-- keyguard.track_shipped, so a user key on the same lhs is reported.
function M.keymaps()
    local registry = require("util.registry")
    for _, entry in ipairs(registry.extra_keys(M.enabled())) do
        registry.apply(entry)
    end
end

-- Keys that enabled extras' plugins create themselves (for util/keyguard).
function M.plugin_keys()
    local out = {}
    for _, name in ipairs(M.enabled()) do
        vim.list_extend(out, vim.deepcopy(M.registry[name].plugin_keys or {}))
    end
    return out
end

function M.setup()
    for _, name in ipairs(M.enabled()) do
        local fn = M.registry[name].setup
        if fn then
            fn()
        end
    end
end

function M.warn_unknown()
    local _, bad = M.requested()
    if #bad > 0 then
        vim.schedule(function()
            vim.notify(
                "vim.g.loki_extras: unknown extra(s): " .. table.concat(bad, ", ")
                    .. ". Available: " .. table.concat(M.order, ", ") .. " (see :LokiExtras).",
                vim.log.levels.WARN
            )
        end)
    end
end

function M.lines()
    local on = {}
    for _, name in ipairs(M.enabled()) do
        on[name] = true
    end
    local lines = {
        "EXTRAS: opt-in features, all off by default",
        "",
        "Enable them in lua/user/options.lua (:LokiEdit options), then restart:",
        '  vim.g.loki_extras = { "sessions", "dashboard" }',
        "",
    }
    for _, name in ipairs(M.order) do
        lines[#lines + 1] = string.format("  [%s] %-10s %s", on[name] and "x" or " ", name, M.registry[name].desc)
    end
    local _, bad = M.requested()
    if #bad > 0 then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Unknown names in vim.g.loki_extras: " .. table.concat(bad, ", ")
    end
    vim.list_extend(lines, { "", "Keys, prerequisites and details: docs/EXTRAS.md. Check tools: :checkhealth loki" })
    return lines
end

-- Runs a terminal program (lazydocker, ...) in a floating toggleterm terminal.
-- Hidden, so it stays out of <C-\> and :TermSelect; toggleterm's Terminal-mode
-- key overrides (jk, <Esc>, <C-h/j/k/l>) are removed so the program keeps them.
local tuis = {}
function M.tui(cmd)
    if not has(cmd) then
        vim.notify(cmd .. " was not found in your PATH. Install it first (:checkhealth loki).", vim.log.levels.WARN)
        return
    end
    local term = tuis[cmd]
    if not term then
        local Terminal = require("toggleterm.terminal").Terminal
        term = Terminal:new({
            cmd = cmd,
            direction = "float",
            hidden = true,
            close_on_exit = true,
            on_open = function(t)
                for _, lhs in ipairs({ "jk", "<Esc>", "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
                    pcall(vim.keymap.del, "t", lhs, { buffer = t.bufnr })
                end
                vim.cmd("startinsert")
            end,
            on_exit = function()
                tuis[cmd] = nil
            end,
        })
        tuis[cmd] = term
    end
    term:toggle()
end

return M
