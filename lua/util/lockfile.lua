-- Where lazy.nvim keeps its lockfile.
--
-- Default: a personal copy in Neovim's data folder, seeded from the repo's
-- lazy-lock.json the first time. Plugins you add or update then never modify a
-- tracked file, so `git pull` stays clean.
--
-- Maintainers who want to commit the lockfile set this in lua/user/options.lua:
--   vim.g.loki_lockfile_in_repo = true
local M = {}

local function shipped()
    return vim.fn.stdpath("config") .. "/lazy-lock.json"
end

local function personal()
    return vim.fn.stdpath("data") .. "/loki-lazy-lock.json"
end

function M.path()
    if vim.g.loki_lockfile_in_repo then
        return shipped()
    end
    local mine = personal()
    if not vim.uv.fs_stat(mine) and vim.uv.fs_stat(shipped()) then
        vim.fn.mkdir(vim.fn.fnamemodify(mine, ":h"), "p")
        vim.uv.fs_copyfile(shipped(), mine)
    end
    return mine
end

function M.setup()
    vim.api.nvim_create_user_command("LokiLockReset", function()
        if vim.g.loki_lockfile_in_repo then
            vim.notify("The lockfile is tracked in the repo, so there is nothing to reset. Use :Lazy restore.")
            return
        end
        if not vim.uv.fs_stat(shipped()) then
            vim.notify("No lazy-lock.json found in the config folder.", vim.log.levels.WARN)
            return
        end
        vim.uv.fs_copyfile(shipped(), personal())
        vim.notify(
            "Plugin versions reset to the ones shipped with this config.\n"
                .. "Restart Neovim, then run :Lazy restore to apply them."
        )
    end, { desc = require("util.registry").command_desc("LokiLockReset") })
end

return M
