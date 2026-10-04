local M = {}

M.groups = {
    { key = "f", label = "Find (files, text, symbols, help)" },
    { key = "w", label = "Windows" },
    { key = "x", label = "Trouble panels (problem lists)" },
    { key = "h", label = "Git (hunks, blame, diff)" },
    { key = "b", label = "Buffers (open files)" },
    { key = "c", label = "Code (format, lint)" },
    { key = "d", label = "Diagnostics and symbols" },
    { key = "i", label = "Inlay hints" },
    { key = "r", label = "Rename" },
}

-- Shipped groups plus any you add in lua/user/options.lua:
--   vim.g.loki_leader_groups = { g = "Git", o = "Notes" }
-- (a list of { key = "g", label = "Git" } tables works too). Yours win.
function M.all()
    local out = vim.deepcopy(M.groups)
    -- Groups of the enabled extras (util/extras.lua) appear only while enabled.
    vim.list_extend(out, require("util.extras").groups())
    local extra = vim.g.loki_leader_groups
    if type(extra) ~= "table" then
        return out
    end

    local function put(key, label)
        if type(key) ~= "string" or type(label) ~= "string" then
            return
        end
        for _, g in ipairs(out) do
            if g.key == key then
                g.label = label
                return
            end
        end
        table.insert(out, { key = key, label = label })
    end

    local named = {}
    for k, v in pairs(extra) do
        if type(k) == "string" then
            table.insert(named, k)
        elseif type(v) == "table" then
            put(v.key, v.label)
        end
    end
    table.sort(named)
    for _, k in ipairs(named) do
        put(k, extra[k])
    end
    return out
end

function M.which_key_spec()
    local spec = {
        { "<leader>?", desc = "Show all keybindings" },
    }

    for _, group in ipairs(M.all()) do
        table.insert(spec, {
            "<leader>" .. group.key,
            group = group.label,
        })
    end

    return spec
end

return M
