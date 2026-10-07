-- Tells you which shipped keys your own lua/user/keymaps.lua replaces, removes
-- or shadows, instead of letting you find out by accident.
--
-- init.lua runs config/keymaps.lua and user/keymaps.lua through track_shipped()
-- and track_user(). While they load, vim.keymap.set/del are wrapped so every
-- call is recorded (the original always still runs). Use vim.keymap.set in your
-- file; raw vim.api.nvim_set_keymap calls are not tracked.
local M = {}

M.shipped = {} -- "mode\0rawlhs" -> { mode, lhs, raw, desc, plugin }
M.overrides = {} -- user key replaced a shipped key
M.removed = {} -- user deleted a shipped key
M.clashes = {} -- user key is a prefix of / extends a shipped key
M.user_set = {} -- "mode\0rawlhs" -> true for every global key set in lua/user/keymaps.lua

-- Keys that plugins set AFTER user keymaps load (so they win over yours).
local PLUGIN_KEYS = {
    { modes = { "n", "i", "t" }, lhs = [[<C-\>]], desc = "Toggle terminal (toggleterm)" },
}

local EXPAND = {
    v = { "x", "s" },
    [""] = { "n", "x", "s", "o" },
    [" "] = { "n", "x", "s", "o" },
    ["!"] = { "i", "c" },
}

local function expand(mode)
    local list = type(mode) == "table" and mode or { mode or "" }
    local out = {}
    for _, m in ipairs(list) do
        vim.list_extend(out, EXPAND[m] or { m })
    end
    return out
end

local function raw(lhs)
    return vim.api.nvim_replace_termcodes(lhs, true, true, true)
end

local function has_desc(opts)
    return type(opts) == "table" and type(opts.desc) == "string" and opts.desc ~= ""
end

local function describe(rhs, opts)
    if type(opts) == "table" and opts.desc then
        return opts.desc
    end
    if rhs == "<Nop>" then
        return "disabled"
    end
    if type(rhs) == "string" and rhs ~= "" then
        return rhs
    end
    return "(no description)"
end

local function skip(lhs, opts)
    return type(lhs) ~= "string" or (type(opts) == "table" and opts.buffer)
end

local function on_shipped(mode, lhs, rhs, opts)
    if skip(lhs, opts) then
        return
    end
    local r = raw(lhs)
    for _, m in ipairs(expand(mode)) do
        M.shipped[m .. "\0" .. r] = {
            mode = m,
            lhs = lhs,
            raw = r,
            desc = describe(rhs, opts),
            nodesc = not has_desc(opts),
        }
    end
end

local function on_user_set(mode, lhs, rhs, opts)
    if skip(lhs, opts) then
        return
    end
    local r = raw(lhs)
    for _, m in ipairs(expand(mode)) do
        M.user_set[m .. "\0" .. r] = true
        local hit = M.shipped[m .. "\0" .. r]
        if hit then
            table.insert(M.overrides, {
                mode = m,
                lhs = lhs,
                was = hit.desc,
                now = describe(rhs, opts),
                plugin = hit.plugin,
            })
        else
            for _, s in pairs(M.shipped) do
                if s.mode == m and s.raw ~= r then
                    if vim.startswith(s.raw, r) then
                        table.insert(M.clashes, { mode = m, short = lhs, long = s.lhs })
                    elseif vim.startswith(r, s.raw) then
                        table.insert(M.clashes, { mode = m, short = s.lhs, long = lhs })
                    end
                end
            end
        end
    end
end

local function on_user_del(mode, lhs, opts)
    if skip(lhs, opts) then
        return
    end
    local r = raw(lhs)
    for _, m in ipairs(expand(mode)) do
        local k = m .. "\0" .. r
        M.user_set[k] = nil
        local hit = M.shipped[k]
        if hit then
            table.insert(M.removed, { mode = m, lhs = lhs, was = hit.desc })
            M.shipped[k] = nil -- the key is free now; setting it again is not an override
            -- A delay that was only caused by the key you just deleted no longer applies.
            for i = #M.clashes, 1, -1 do
                local c = M.clashes[i]
                if c.mode == m and c.long == hit.lhs then
                    table.remove(M.clashes, i)
                end
            end
        end
    end
end

local function watch(on_set, on_del, fn)
    local set, del = vim.keymap.set, vim.keymap.del
    vim.keymap.set = function(mode, lhs, rhs, opts)
        pcall(on_set, mode, lhs, rhs, opts)
        return set(mode, lhs, rhs, opts)
    end
    vim.keymap.del = function(mode, lhs, opts)
        pcall(on_del, mode, lhs, opts)
        return del(mode, lhs, opts)
    end
    local ok, err = pcall(fn)
    vim.keymap.set, vim.keymap.del = set, del
    if not ok then
        error(err, 0)
    end
end

-- True when lua/user/keymaps.lua set this key globally. util/lsp.lua uses it so
-- a buffer-local LSP key never shadows a key the user chose.
function M.user_owns(mode, lhs)
    local r = raw(lhs)
    for _, m in ipairs(expand(mode)) do
        if M.user_set[m .. "\0" .. r] then
            return true
        end
    end
    return false
end

function M.track_shipped(fn)
    watch(on_shipped, function() end, fn)
    local plugin_keys = vim.list_extend(vim.deepcopy(PLUGIN_KEYS), require("util.extras").plugin_keys())
    for _, p in ipairs(plugin_keys) do
        local r = raw(p.lhs)
        for _, m in ipairs(p.modes) do
            M.shipped[m .. "\0" .. r] = { mode = m, lhs = p.lhs, raw = r, desc = p.desc, plugin = true }
        end
    end
end

function M.track_user(fn)
    watch(on_user_set, on_user_del, fn)
end

-- Merge per-mode records into one row per key ("x" and "s" become "xs").
local function merge(list, keyfn, build)
    local order, by = {}, {}
    for _, item in ipairs(list) do
        local k = keyfn(item)
        if not by[k] then
            by[k] = build(item)
            by[k].modes = ""
            table.insert(order, by[k])
        end
        if not by[k].modes:find(item.mode, 1, true) then
            by[k].modes = by[k].modes .. item.mode
        end
    end
    return order
end

function M.overrides_grouped()
    return merge(M.overrides, function(o)
        return o.lhs .. "\0" .. o.was .. "\0" .. o.now
    end, function(o)
        return { lhs = o.lhs, was = o.was, now = o.now, plugin = o.plugin }
    end)
end

function M.removed_grouped()
    return merge(M.removed, function(o)
        return o.lhs .. "\0" .. o.was
    end, function(o)
        return { lhs = o.lhs, was = o.was }
    end)
end

function M.clashes_grouped()
    return merge(M.clashes, function(o)
        return o.short .. "\0" .. o.long
    end, function(o)
        return { short = o.short, long = o.long }
    end)
end

function M.report_lines()
    local o, r, c = M.overrides_grouped(), M.removed_grouped(), M.clashes_grouped()
    if #o + #r + #c == 0 then
        return { "None of your keymaps replace, remove or shadow a shipped key." }
    end
    local lines = {}
    local function add(s)
        lines[#lines + 1] = s
    end

    if #o > 0 then
        add("Replaced (the shipped action no longer runs on that key):")
        for _, x in ipairs(o) do
            add(
                string.format(
                    '  %s (%s): was "%s", now "%s"%s',
                    x.lhs,
                    x.modes,
                    x.was,
                    x.now,
                    x.plugin and "  [plugin key: the plugin may still win]" or ""
                )
            )
        end
        add("")
    end
    if #r > 0 then
        add("Removed (you deleted the shipped key):")
        for _, x in ipairs(r) do
            add(string.format('  %s (%s): was "%s"', x.lhs, x.modes, x.was))
        end
        add("")
    end
    if #c > 0 then
        add(string.format("Delays: the shorter key waits %d ms for a possible longer one:", vim.o.timeoutlen))
        for _, x in ipairs(c) do
            add(string.format("  %s (%s) waits because %s also exists", x.short, x.modes, x.long))
        end
        add("")
    end
    add("Fix: use another key, move the shipped action to a new key in the same")
    add("file, or delete your line to get the shipped key back. Pick keys that are")
    add("not the start of another key. The shipped action is still reachable as a")
    add("command: search it with <leader>fc.")
    return lines
end

local function signature()
    local parts = {}
    for _, o in ipairs(M.overrides_grouped()) do
        parts[#parts + 1] = "o:" .. o.modes .. ":" .. o.lhs
    end
    for _, o in ipairs(M.removed_grouped()) do
        parts[#parts + 1] = "r:" .. o.modes .. ":" .. o.lhs
    end
    for _, o in ipairs(M.clashes_grouped()) do
        parts[#parts + 1] = "c:" .. o.modes .. ":" .. o.short .. ":" .. o.long
    end
    table.sort(parts)
    return table.concat(parts, "\n")
end

function M.setup()
    vim.api.nvim_create_user_command("LokiKeys", function()
        local lines = { "Shipped keys versus your lua/user/keymaps.lua", "" }
        vim.list_extend(lines, M.report_lines())
        vim.list_extend(lines, { "", "Search any key: <leader>fk     Full check: :checkhealth loki" })
        require("util.welcome").show(lines, "Your keys")
    end, { desc = require("util.registry").command_desc("LokiKeys") })

    -- Tell the user once per change, not on every start.
    local sig = signature()
    local path = vim.fn.stdpath("state") .. "/loki-keys-seen"
    local last = ""
    if vim.fn.filereadable(path) == 1 then
        last = table.concat(vim.fn.readfile(path), "\n")
    end
    if sig == last then
        return
    end
    local function remember()
        pcall(function()
            vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
            vim.fn.writefile(vim.split(sig, "\n"), path)
        end)
    end
    if sig == "" then
        remember() -- conflicts were cleared; nothing to show
    else
        local n = #M.overrides_grouped() + #M.removed_grouped()
        local msg = string.format(
            "Loki: your keymaps replace or remove %d shipped key(s)%s. Run :LokiKeys to review.",
            n,
            #M.clashes_grouped() > 0 and " and delay some others" or ""
        )
        vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = function()
                -- Headless runs (smoke test, cheatsheet watcher) must not use up the notice.
                if #vim.api.nvim_list_uis() == 0 then
                    return
                end
                remember()
                vim.defer_fn(function()
                    vim.notify(msg, vim.log.levels.WARN)
                end, 600)
            end,
        })
    end
end

return M
