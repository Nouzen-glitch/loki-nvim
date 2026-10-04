-- Extra "lint": nvim-lint. Linters come from the `linter` field of the language
-- table (config/languages.lua + languages_local.lua); Mason installs the `tools`.
-- A linter whose program is not installed is skipped silently (see :checkhealth loki).
return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufNewFile", "BufWritePost" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = require("util.languages").linters_by_ft()

            local function run()
                -- Public API only; "a.b" filetypes use the linters of both parts.
                local names = {}
                for _, ft in ipairs(vim.split(vim.bo.filetype, ".", { plain = true })) do
                    vim.list_extend(names, lint.linters_by_ft[ft] or {})
                end
                local usable = {}
                for _, name in ipairs(names) do
                    local linter = lint.linters[name]
                    if type(linter) == "function" then
                        linter = linter()
                    end
                    local cmd = linter and linter.cmd
                    if type(cmd) == "function" then
                        cmd = cmd()
                    end
                    if type(cmd) == "string" and vim.fn.executable(cmd) == 1 then
                        usable[#usable + 1] = name
                    end
                end
                if #usable > 0 then
                    lint.try_lint(usable)
                end
            end

            vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("LokiLint", { clear = true }),
                callback = run,
            })
        end,
    },
}
