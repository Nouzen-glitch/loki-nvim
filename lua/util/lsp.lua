-- LSP keys. The keys of util/registry.lua that have an `lsp` field are
--   * created GLOBALLY by config/keymaps.lua as a friendly notice (so the key is
--     listed in which-key everywhere and never ends in a raw error), and
--   * created BUFFER-LOCALLY here when a language server attaches.
-- A key you set yourself in lua/user/keymaps.lua is never replaced here: yours wins.
local M = {}

M.actions = {
    hover = function()
        vim.lsp.buf.hover()
    end,
    definition = function()
        vim.lsp.buf.definition()
    end,
    declaration = function()
        vim.lsp.buf.declaration()
    end,
    implementation = function()
        vim.lsp.buf.implementation()
    end,
    references = function()
        vim.lsp.buf.references()
    end,
    rename = function()
        vim.lsp.buf.rename()
    end,
    code_action = function()
        vim.lsp.buf.code_action()
    end,
    type_definition = function()
        vim.lsp.buf.type_definition()
    end,
    document_symbol = function()
        vim.lsp.buf.document_symbol()
    end,
    incoming_calls = function()
        vim.lsp.buf.incoming_calls()
    end,
    outgoing_calls = function()
        vim.lsp.buf.outgoing_calls()
    end,
    inlay_hints = function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
    end,
}

-- Shown by the global fallback key when no server is attached to the buffer.
function M.notice(entry)
    local ft = vim.bo.filetype
    local first = type(entry.lhs) == "table" and entry.lhs[1] or entry.lhs
    vim.notify(
        string.format(
            "%s (%s) needs a language server, and none is attached to this buffer (filetype: %s).\n"
                .. "Run :LokiLsp to see why and what to do.",
            entry.desc,
            first,
            ft ~= "" and ft or "none"
        ),
        vim.log.levels.WARN
    )
end

function M.attach(bufnr)
    local registry = require("util.registry")
    local keyguard = require("util.keyguard")
    for _, e in ipairs(registry.keys) do
        if e.lsp and M.actions[e.lsp] then
            for _, lhs in ipairs(registry.as_list(e.lhs)) do
                for _, mode in ipairs(registry.as_list(e.mode)) do
                    if not keyguard.user_owns(mode, lhs) then
                        vim.keymap.set(mode, lhs, M.actions[e.lsp], { buffer = bufnr, desc = e.desc })
                    end
                end
            end
        end
    end
end

function M.setup()
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("LokiLsp", { clear = true }),
        callback = function(args)
            M.attach(args.buf)
        end,
    })
end

-- ---------------------------------------------------------------------------
-- :LokiLsp
-- ---------------------------------------------------------------------------

local function exe_of(cmd)
    if type(cmd) == "table" then
        cmd = cmd[1]
    end
    return type(cmd) == "string" and vim.fn.executable(cmd) == 1
end

function M.report(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    local name = vim.api.nvim_buf_get_name(bufnr)
    local langs = require("util.languages")
    local entry = langs.entry(ft)
    local lines = {
        "LANGUAGE SUPPORT FOR THIS BUFFER",
        "",
        "  File:      " .. (name ~= "" and vim.fn.fnamemodify(name, ":~") or "(no name)"),
        "  Filetype:  " .. (ft ~= "" and ft or "(none)"),
        "",
    }
    local add = function(s)
        lines[#lines + 1] = s
    end

    add("LANGUAGE SERVERS")
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients == 0 then
        add("  None attached.")
    else
        for _, c in ipairs(clients) do
            add(
                string.format(
                    "  %s   root: %s",
                    c.name,
                    c.root_dir and vim.fn.fnamemodify(c.root_dir, ":~") or "(single file)"
                )
            )
        end
    end
    add("")

    add("FORMATTER")
    local ok, conform = pcall(require, "conform")
    if ok then
        local infos = conform.list_formatters(bufnr)
        if #infos == 0 then
            add("  None for this filetype" .. (#clients > 0 and "; <leader>cf falls back to the server." or "."))
        else
            for _, f in ipairs(infos) do
                add("  " .. f.name .. (f.available and "" or "   (NOT INSTALLED: see :Mason)"))
            end
        end
    else
        add("  Conform is not loaded yet.")
    end
    add("")

    add("SYNTAX (TREE-SITTER)")
    local has_parser = vim.treesitter.highlighter.active[bufnr] ~= nil
    add("  " .. (has_parser and "Highlighting is active." or "Not active for this buffer."))
    add("")

    add("LANGUAGE TABLE ENTRY")
    if entry then
        add(
            "  lsp: "
                .. tostring(entry.lsp or "-")
                .. "   parser: "
                .. tostring(type(entry.parser) == "table" and table.concat(entry.parser, ",") or entry.parser or "-")
        )
        add(
            "  formatter: "
                .. tostring(
                    type(entry.formatter) == "table" and table.concat(entry.formatter, ",") or entry.formatter or "-"
                )
                .. "   linter: "
                .. tostring(type(entry.linter) == "table" and table.concat(entry.linter, ",") or entry.linter or "-")
        )
    else
        add("  No entry for filetype '" .. ft .. "'.")
    end
    add("")

    add("WHAT TO DO")
    if #clients > 0 then
        add("  A server is attached: gd, gr, K, <leader>rn and <leader>ca work in this buffer.")
        add("  If one of them still fails, the server may not support it: :checkhealth vim.lsp")
    elseif ft == "" then
        add("  The buffer has no filetype. Save it with an extension, or :set filetype=<name>.")
    elseif not entry or not entry.lsp then
        add("  The language table has no server for '" .. ft .. "'. Add one:")
        add("    :LokiEdit languages   then a line such as")
        add("    " .. ft .. ' = { lsp = "<lspconfig name>", parser = "' .. ft .. '" },')
        add("  Names: :help lspconfig-all. Restart Neovim afterwards.")
    else
        local servers = type(entry.lsp) == "table" and entry.lsp or { entry.lsp }
        for _, s in ipairs(servers) do
            local cfg = vim.lsp.config[s]
            if not cfg then
                add("  '" .. s .. "' is not a known lspconfig server name. Check the spelling (:help lspconfig-all).")
            elseif not exe_of(cfg.cmd) then
                add("  Server '" .. s .. "' is not installed (command not found). Open :Mason and install it,")
                add("  or restart Neovim: missing servers install themselves. :MasonLog shows errors.")
                add("  Mason needs Node.js, Python 3 or Go depending on the server (:checkhealth loki).")
            elseif vim.lsp.is_enabled and not vim.lsp.is_enabled(s) then
                add(
                    "  Server '"
                        .. s
                        .. "' is installed but not enabled. Restart Neovim; it must be in the language table."
                )
            else
                add("  Server '" .. s .. "' is installed and enabled but did not attach. Usual causes:")
                add("    - the file is outside a project root the server recognises (a .git folder or a project file)")
                add("    - the server crashed: :LspLog, and :checkhealth vim.lsp")
            end
        end
    end
    add("")
    add("More: :LokiHelp lsp   docs/LSP.md   :checkhealth loki")
    return lines
end

return M
