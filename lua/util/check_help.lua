-- Help-system consistency check (scripts/check-help.sh). Calls :cquit when
-- anything is missing or out of date, and prints every problem it found.
local registry = require("util.registry")
local M = {}

local function read(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local text = f:read("*a")
    f:close()
    return text
end

-- GitHub-style heading anchors of a markdown file.
local function anchors(text)
    local out = {}
    for line in text:gmatch("[^\n]+") do
        local h = line:match("^#+%s+(.+)$")
        if h then
            local slug = h:lower():gsub("`", ""):gsub("[^%w%s%-_]", ""):gsub("%s", "-")
            out[slug] = true
        end
    end
    return out
end

function M.run()
    local root = vim.uv.fs_realpath(vim.fn.stdpath("config")) or vim.fn.stdpath("config")
    local problems = {}
    local function bad(msg) problems[#problems + 1] = msg end

    local docs = {}
    local function doc(name)
        if docs[name] == nil then
            docs[name] = read(root .. "/docs/" .. name) or false
        end
        return docs[name]
    end

    local function check_see(what, see)
        if not see then
            return
        end
        local file, anchor = see:match("^docs/([%w_%.]+)#?(.*)$")
        if not file then
            bad(what .. ": bad `see` value '" .. see .. "'")
            return
        end
        local text = doc(file)
        if not text then
            bad(what .. ": docs/" .. file .. " does not exist (see = '" .. see .. "')")
        elseif anchor ~= "" and not anchors(text)[anchor] then
            bad(what .. ": docs/" .. file .. " has no heading for #" .. anchor)
        end
    end

    -- 1. every shipped mapping has a description (recorded by util/keyguard)
    local kg = require("util.keyguard")
    local prefixes = {}
    for _, g in ipairs(require("config.leader_groups").all()) do
        prefixes[g.key] = true
    end
    for _, s in pairs(kg.shipped) do
        if s.nodesc then
            bad(string.format("mapping %s (%s) has no desc", s.lhs, s.mode))
        end
        -- 2. every <leader>XY... prefix has a group label
        local rest = type(s.lhs) == "string" and s.lhs:match("^<leader>(.+)$")
        if rest and #rest >= 2 and not rest:match("^<") and not prefixes[rest:sub(1, 1)] then
            bad(string.format("mapping %s: <leader>%s has no group label (config/leader_groups.lua)", s.lhs, rest:sub(1, 1)))
        end
    end

    -- 3. user commands have a description and a registry entry
    local ok, cmds = pcall(vim.api.nvim_get_commands, { builtin = false })
    local ours = {}
    if ok then
        for name, c in pairs(cmds) do
            if name:match("^Loki") or name:match("^Cheatsheet") then
                ours[name] = true
                if (c.definition or "") == "" then
                    bad("command :" .. name .. " has no desc")
                end
                if not registry.command(name) then
                    bad("command :" .. name .. " is missing from registry.commands")
                end
            end
        end
    end
    for _, c in ipairs(registry.commands) do
        if not ours[c.name] then
            bad("registry command :" .. c.name .. " is not defined")
        end
    end

    -- 4. registry completeness
    local groups_in_topics = {}
    for _, t in pairs(registry.topics) do
        for _, g in ipairs(t.groups or {}) do
            groups_in_topics[g] = true
        end
        check_see("topic " .. t.tag, t.see)
        if #(t.intro or {}) == 0 then
            bad("topic " .. t.tag .. " has no intro")
        end
    end
    local lsp_actions = require("util.lsp").actions
    for _, e in ipairs(registry.keys) do
        local id = table.concat(registry.as_list(e.lhs), " ") .. " [" .. table.concat(registry.as_list(e.mode), ",") .. "]"
        if not e.desc or e.desc == "" then bad("registry key " .. id .. " lacks desc") end
        if not e.long or #e.long < 30 then bad("registry key " .. id .. " lacks a `long` text") end
        if not e.group then
            bad("registry key " .. id .. " lacks group")
        elseif not groups_in_topics[e.group] then
            bad("registry group '" .. e.group .. "' (key " .. id .. ") is in no help topic")
        end
        if e.lsp and not lsp_actions[e.lsp] then bad("registry key " .. id .. ": unknown lsp action " .. e.lsp) end
        if not e.lsp and e.set ~= false and e.rhs == nil then bad("registry key " .. id .. " has no rhs") end
        check_see("registry key " .. id, e.see)
    end
    for _, c in ipairs(registry.commands) do
        if not c.desc or c.desc == "" then bad("registry command :" .. c.name .. " lacks desc") end
        if not c.long or #c.long < 30 then bad("registry command :" .. c.name .. " lacks a `long` text") end
        check_see("registry command :" .. c.name, c.see)
    end

    -- 5. every shipped key is in docs/KEYBINDINGS.md
    local kb = doc("KEYBINDINGS.md") or ""
    for _, e in ipairs(registry.keys) do
        local found = e.doc and kb:find(e.doc, 1, true)
        if not found then
            found = true
            for _, lhs in ipairs(registry.as_list(e.lhs)) do
                if not kb:find("`" .. lhs .. "`", 1, true) then
                    found = false
                end
            end
        end
        if not found then
            bad("docs/KEYBINDINGS.md does not mention " .. table.concat(registry.as_list(e.lhs), " "))
        end
    end

    -- 6. every command is in the Environment Guide's command table
    local env = doc("ENVIRONMENT_GUIDE.md") or ""
    for _, c in ipairs(registry.commands) do
        if not env:find(":" .. c.name, 1, true) then
            bad("docs/ENVIRONMENT_GUIDE.md does not list :" .. c.name)
        end
    end

    -- 7. extras are documented everywhere the Environment Guide says
    local extras = require("util.extras")
    local extras_md, comps = doc("EXTRAS.md") or "", doc("COMPONENTS.md") or ""
    for _, name in ipairs(extras.order) do
        if not extras_md:find("`" .. name .. "`", 1, true) then bad("docs/EXTRAS.md does not mention extra `" .. name .. "`") end
        if not comps:find("| " .. name .. " |", 1, true) then bad("docs/COMPONENTS.md has no row for extra " .. name) end
        if not kb:find(name, 1, true) then bad("docs/KEYBINDINGS.md does not mention extra " .. name) end
        if extras.registry[name].plugins and not vim.uv.fs_stat(root .. "/lua/extras/" .. name .. ".lua") then
            bad("extra " .. name .. " says plugins = true but lua/extras/" .. name .. ".lua is missing")
        end
    end

    -- 8. every docs file is linked from docs/README.md
    local readme = doc("README.md") or ""
    for name, kind in vim.fs.dir(root .. "/docs") do
        if kind == "file" and name:match("%.md$") and name ~= "README.md" and not readme:find(name, 1, true) then
            bad("docs/README.md does not link docs/" .. name)
        end
    end

    -- 9. doc/loki.txt is current and :help loki works
    local helpdoc = require("util.helpdoc")
    local current = read(helpdoc.doc_dir() .. "/loki.txt")
    local expected = table.concat(helpdoc.vimdoc(), "\n") .. "\n"
    if not current then
        bad("doc/loki.txt is missing (run scripts/gen-help.sh)")
    elseif current ~= expected then
        bad("doc/loki.txt is out of date (run scripts/gen-help.sh)")
    else
        helpdoc.ensure_tags()
        local tags = vim.fn.getcompletion("loki", "help")
        for _, want in ipairs({ "loki", "loki-keys", "loki-lsp", "loki-git", "loki-languages", "loki-extras", "loki-files", "loki-troubleshooting" }) do
            if not vim.tbl_contains(tags, want) then
                bad("help tag *" .. want .. "* not found (:help " .. want .. ")")
            end
        end
    end

    if #problems > 0 then
        io.stderr:write("HELP CHECK FAILED (" .. #problems .. "):\n  " .. table.concat(problems, "\n  ") .. "\n")
        vim.cmd("cquit 1")
    end
    print("check-help: ok")
end

return M
