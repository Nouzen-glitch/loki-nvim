-- Formatters ignore Neovim's shiftwidth: clang-format falls back to 2-space LLVM
-- style, Prettier defaults to 2 spaces, StyLua to tabs. When the project has no
-- config of its own, hand them the buffer's indent so format on save agrees with
-- what the editor just did. A project's own config always wins.
local function indent_of(bufnr)
    local sw = vim.bo[bufnr].shiftwidth
    if sw == 0 then
        sw = vim.bo[bufnr].tabstop
    end
    return sw, vim.bo[bufnr].tabstop, vim.bo[bufnr].expandtab
end

local function has_config(ctx, names)
    local dir = vim.fs.dirname(ctx.filename)
    return #vim.fs.find(names, { upward = true, path = dir, limit = 1, stop = vim.uv.os_homedir() }) > 0
end

local function prettier_configured(ctx)
    if
        has_config(ctx, {
            ".prettierrc",
            ".prettierrc.json",
            ".prettierrc.yml",
            ".prettierrc.yaml",
            ".prettierrc.json5",
            ".prettierrc.js",
            ".prettierrc.cjs",
            ".prettierrc.mjs",
            ".prettierrc.toml",
            "prettier.config.js",
            "prettier.config.cjs",
            "prettier.config.mjs",
            ".editorconfig",
        })
    then
        return true
    end
    -- A "prettier" key in package.json counts as config too.
    local pkg = vim.fs.find("package.json", { upward = true, path = vim.fs.dirname(ctx.filename), limit = 1 })[1]
    if pkg then
        local ok, lines = pcall(vim.fn.readfile, pkg)
        return ok and table.concat(lines, "\n"):find('"prettier"%s*:') ~= nil
    end
    return false
end

return {
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- Built from config/languages.lua (+ languages_local.lua).
            formatters_by_ft = require("util.languages").formatters_by_ft(),

            formatters = {
                clang_format = {
                    -- Without a .clang-format, clang-format would use 2-space LLVM style.
                    prepend_args = function(_, ctx)
                        if has_config(ctx, { ".clang-format", "_clang-format" }) then
                            return {}
                        end
                        local sw, ts, et = indent_of(ctx.buf)
                        return {
                            ("--style={BasedOnStyle: LLVM, IndentWidth: %d, TabWidth: %d, UseTab: %s}"):format(
                                sw,
                                ts,
                                et and "Never" or "Always"
                            ),
                        }
                    end,
                },
                prettier = {
                    prepend_args = function(_, ctx)
                        if prettier_configured(ctx) then
                            return {}
                        end
                        local sw, _, et = indent_of(ctx.buf)
                        local args = { "--tab-width", tostring(sw) }
                        if not et then
                            table.insert(args, "--use-tabs")
                        end
                        return args
                    end,
                },
                stylua = {
                    prepend_args = function(_, ctx)
                        if has_config(ctx, { ".stylua.toml", "stylua.toml" }) then
                            return {}
                        end
                        local sw, _, et = indent_of(ctx.buf)
                        return { "--indent-type", et and "Spaces" or "Tabs", "--indent-width", tostring(sw) }
                    end,
                },
            },

            format_on_save = function(bufnr)
                -- :LokiFormat off turns format on save off for this session.
                if vim.g.loki_format_on_save == false then
                    return
                end
                -- Disable automatic formatting for huge files.
                local max_size = 200 * 1024 -- 200 KB
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
                if ok and stats and stats.size > max_size then
                    return
                end
                return {
                    timeout_ms = 1000,
                    lsp_format = "fallback",
                }
            end,
        },
    },
}
