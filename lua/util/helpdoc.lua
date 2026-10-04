-- Renders the help topics of util/registry.lua two ways, from the same data:
--   M.topic_lines(name)  lines for the :LokiHelp window
--   M.vimdoc()           the text of doc/loki.txt (:help loki)
-- doc/loki.txt is GENERATED: run scripts/gen-help.sh after changing the registry.
-- scripts/check-help.sh fails when the committed file is out of date.
local registry = require("util.registry")
local M = {}

local function wrap(text, width, indent)
    local pad = string.rep(" ", indent)
    -- Lines that start with whitespace are code or examples: keep them as written.
    if text:match("^%s") then
        return { pad .. text }
    end
    local out, line = {}, ""
    for word in text:gmatch("%S+") do
        if line == "" then
            line = word
        elseif #line + 1 + #word > width - indent then
            out[#out + 1] = pad .. line
            line = word
        else
            line = line .. " " .. word
        end
    end
    if line ~= "" then
        out[#out + 1] = pad .. line
    end
    return out
end

local function modes_of(e)
    return table.concat(registry.as_list(e.mode), ",")
end

local function lhs_of(e)
    return table.concat(registry.as_list(e.lhs), " ")
end

local function key_entries(topic, add, o)
    local entries = registry.topic_keys(topic)
    if #entries == 0 then
        return
    end
    local last
    for _, e in ipairs(entries) do
        if e.group ~= last then
            add("")
            add(o.vimdoc and ("    " .. e.group) or ("  " .. e.group:upper()))
            last = e.group
        end
        local head = o.vimdoc and string.format("    `%s`  [%s]  %s", lhs_of(e), modes_of(e), e.desc)
            or string.format("    %s  [%s]", lhs_of(e), modes_of(e))
        if o.vimdoc then
            for _, l in ipairs(wrap(head:gsub("^%s+", ""), 76, 4)) do add(l) end
        else
            add(head)
            for _, l in ipairs(wrap(e.desc, o.width, 8)) do add(l) end
        end
        for _, l in ipairs(wrap(e.long, o.width, 8)) do add(l) end
        if e.example then
            add("        Example: " .. e.example)
        end
        add("")
    end
end

local function body(name, o)
    local t = registry.topics[name]
    local lines = {}
    local function add(s) lines[#lines + 1] = s end

    for _, p in ipairs(t.intro) do
        for _, l in ipairs(wrap(p, o.width, 0)) do add(l) end
    end

    key_entries(name, add, o)

    if t.commands and #t.commands > 0 then
        add("")
        add(o.vimdoc and "    Commands" or "COMMANDS")
        for _, cname in ipairs(t.commands) do
            local c = registry.command(cname)
            add(string.format("    :%s%s", c.name, c.args and (" " .. c.args) or ""))
            for _, l in ipairs(wrap(c.desc .. ". " .. c.long, o.width, 8)) do add(l) end
            if c.example then add("        Example: " .. c.example) end
        end
    end

    if t.fail and #t.fail > 0 then
        add("")
        add(o.vimdoc and "    If it does not work" or "IF IT DOES NOT WORK")
        for _, f in ipairs(t.fail) do
            local w = wrap(f, o.width, 4)
            w[1] = "  - " .. w[1]:sub(5)
            vim.list_extend(lines, w)
        end
    end

    add("")
    add(o.vimdoc and ("    More: " .. t.see .. "   (:LokiDocs browses the docs)")
        or ("MORE: " .. t.see .. "   :help " .. t.tag .. "   :LokiDocs"))
    return lines
end

-- Lines for the :LokiHelp window.
function M.topic_lines(name)
    local t = registry.topics[name]
    local lines = { "LOKI HELP: " .. t.title:upper(), "" }
    vim.list_extend(lines, body(name, { width = 74 }))
    vim.list_extend(lines, { "", "Other topics: :LokiHelp <topic>  (" .. table.concat(registry.topic_order, ", ") .. ")" })
    return lines
end

-- Right-aligns a *tag* on a heading line, vimdoc style.
local function with_tag(text, tag)
    local tagtxt = "*" .. tag .. "*"
    local gap = math.max(2, 78 - #text - #tagtxt)
    return text .. string.rep(" ", gap) .. tagtxt
end

function M.vimdoc()
    local lines = {}
    local function add(s) lines[#lines + 1] = s end
    local rule = string.rep("=", 78)

    add("*loki.txt*  Loki Neovim: keys, commands and features")
    add("")
    add(rule)
    add("CONTENTS                                                          *loki-contents*")
    add("")
    local function toc(n, title, tag)
        local left = string.format("    %d. %s ", n, title)
        add(left .. string.rep(".", math.max(2, 58 - #left)) .. " |" .. tag .. "|")
    end
    toc(1, "Overview", "loki")
    for i, name in ipairs(registry.topic_order) do
        toc(i + 1, registry.topics[name].title, registry.topics[name].tag)
    end
    toc(#registry.topic_order + 2, "Commands", "loki-commands")
    add("")
    add("This file is generated from lua/util/registry.lua (scripts/gen-help.sh). The same text")
    add("is shown by :LokiHelp. Longer guides live in the docs/ folder; :LokiDocs browses them.")
    add("")
    add(rule)
    add(with_tag("1. Overview", "loki"))
    add("")
    for _, p in ipairs({
        "Loki Neovim is a Neovim configuration with LSP, completion, fuzzy finding, git, formatting and an integrated terminal. <leader> is the Space bar.",
        "Find your way: <leader>? lists every key, <leader>fk searches keys, <leader>fc searches commands, :LokiHelp opens the one-screen guide.",
        "Check your setup with :checkhealth loki.",
    }) do
        for _, l in ipairs(wrap(p, 76, 4)) do add(l) end
    end

    for i, name in ipairs(registry.topic_order) do
        local t = registry.topics[name]
        add("")
        add(rule)
        add(with_tag(string.format("%d. %s", i + 1, t.title), t.tag))
        add("")
        local b = body(name, { width = 78, vimdoc = true })
        for _, l in ipairs(b) do
            -- body lines of intro text start at column 0; indent them for readability.
            add(l == "" and "" or (l:match("^ ") and l or ("    " .. l)))
        end
    end

    add("")
    add(rule)
    add(with_tag(string.format("%d. Commands", #registry.topic_order + 2), "loki-commands"))
    add("")
    for _, c in ipairs(registry.commands) do
        local head = ":" .. c.name .. (c.args and (" " .. c.args) or "")
        add(with_tag(head, ":" .. c.name))
        for _, l in ipairs(wrap(c.desc .. ". " .. c.long, 78, 8)) do add(l) end
        if c.example then add("        Example: " .. c.example) end
        add("")
    end
    add(" vim:tw=78:ts=8:ft=help:norl:")
    return lines
end

function M.doc_dir()
    return (vim.uv.fs_realpath(vim.fn.stdpath("config")) or vim.fn.stdpath("config")) .. "/doc"
end

function M.write()
    local dir = M.doc_dir()
    vim.fn.mkdir(dir, "p")
    vim.fn.writefile(M.vimdoc(), dir .. "/loki.txt")
    return dir .. "/loki.txt"
end

-- doc/tags is not committed (it is gitignored): build it when missing or older than loki.txt,
-- so :help loki works on a fresh install.
function M.ensure_tags()
    local dir = M.doc_dir()
    local txt, tags = vim.uv.fs_stat(dir .. "/loki.txt"), vim.uv.fs_stat(dir .. "/tags")
    if not txt then
        return
    end
    if tags and tags.mtime.sec >= txt.mtime.sec then
        return
    end
    pcall(vim.cmd, "silent! helptags " .. vim.fn.fnameescape(dir))
end

return M
