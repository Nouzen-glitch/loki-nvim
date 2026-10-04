-- Builds the LSP / parser / formatter / tool lists from config.languages
-- (plus the optional config.languages_local). Used by plugins/lsp.lua,
-- treesitter.lua and formatting.lua.
local M = {}

local function as_list(value)
    if value == nil then
        return {}
    elseif type(value) == "table" then
        return value
    end
    return { value }
end

-- The merged table is built once per session (a restart picks up edits), so a
-- syntax error in languages_local.lua is reported once, not once per caller.
local cache

local function load()
    if cache then
        return cache
    end
    local langs = vim.deepcopy(require("config.languages"))

    local ok, extra = pcall(require, "config.languages_local")
    if ok then
        if type(extra) == "table" then
            for ft, cfg in pairs(extra) do
                langs[ft] = cfg or nil -- `false` removes a default
            end
        end
    elseif not tostring(extra):find("module 'config.languages_local' not found", 1, true) then
        vim.schedule(function()
            vim.notify("languages_local.lua error:\n" .. tostring(extra), vim.log.levels.ERROR)
        end)
    end

    cache = langs
    return langs
end

local function collect(field)
    local items = {}
    for _, cfg in pairs(load()) do
        if type(cfg) == "table" then
            for _, item in ipairs(as_list(cfg[field])) do
                if type(item) == "string" then -- bad values are reported by M.problems()
                    items[#items + 1] = item
                end
            end
        end
    end
    table.sort(items)

    local seen, out = {}, {}
    for _, item in ipairs(items) do
        if not seen[item] then
            seen[item] = true
            table.insert(out, item)
        end
    end
    return out
end

function M.servers() return collect("lsp") end
function M.parsers() return collect("parser") end
function M.tools() return collect("tools") end

-- The merged entry of one filetype (nil when there is none).
function M.entry(ft)
    local cfg = load()[ft]
    return type(cfg) == "table" and cfg or nil
end

-- nvim-lint linters per filetype (used by the "lint" extra).
function M.linters_by_ft()
    local out = {}
    for ft, cfg in pairs(load()) do
        if type(cfg) == "table" and cfg.linter then
            out[ft] = as_list(cfg.linter)
        end
    end
    return out
end

function M.formatters_by_ft()
    local out = {}
    for ft, cfg in pairs(load()) do
        if type(cfg) == "table" and cfg.formatter then
            out[ft] = as_list(cfg.formatter)
        end
    end
    return out
end

-- Human-readable problems in the language table (typos, wrong types).
-- Shown by :checkhealth loki; startup keeps working without the bad values.
local FIELDS = { lsp = true, parser = true, formatter = true, linter = true, tools = true }
 
function M.problems()
    local out = {}
    for ft, cfg in pairs(load()) do
        if type(cfg) ~= "table" then
            out[#out + 1] = string.format('%s: the entry must be a table (use "%s = false" to disable a language)', ft, ft)
        else
            for key, value in pairs(cfg) do
                if not FIELDS[key] then
                    out[#out + 1] = string.format('%s: unknown field "%s" (use lsp, parser, formatter, linter, tools)', ft, tostring(key))
                else
                    for _, item in ipairs(as_list(value)) do
                        if type(item) ~= "string" then
                            out[#out + 1] = string.format("%s.%s: values must be strings", ft, key)
                            break
                        end
                    end
                end
            end
        end
    end
    table.sort(out)
    return out
end
 
return M
