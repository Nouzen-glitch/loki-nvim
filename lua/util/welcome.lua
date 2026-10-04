-- Tells the user, once, what scripts/install.sh did (backup location, how to
-- start, how to undo). The installer writes <state>/loki-install-info; the
-- first launch shows it in a centered window and renames the file to *.shown.
-- `:LokiInfo` shows it again. A config that was cloned by hand (no install
-- record) gets a one-time notice explaining what it is missing.
-- M.show(lines, title) is reused by :LokiHelp and :LokiKeys.
local M = {}

local function paths()
    local base = vim.fn.stdpath("state") .. "/loki-install-info"
    return base, base .. ".shown"
end

local function read(path)
    local info = {}
    for _, line in ipairs(vim.fn.readfile(path)) do
        local key, value = line:match("^(%w+)=(.*)$")
        if key then
            info[key] = value
        end
    end
    return info
end

local function message(info)
    local lines = { "Loki Neovim was installed (" .. (info.mode or "unknown") .. " mode).", "" }

    if info.backup and info.backup ~= "" then
        table.insert(lines, "Your previous config was moved to:")
        table.insert(lines, "  " .. info.backup)
    elseif info.mode == "alongside" then
        table.insert(lines, "Your existing Neovim config was not touched.")
    else
        table.insert(lines, "Nothing needed backing up.")
    end

    if info.launcher and info.launcher ~= "" then
        table.insert(lines, "")
        table.insert(lines, "Start this config with: " .. vim.fs.basename(info.launcher))
    end
    if info.source and info.source ~= "" then
        table.insert(lines, "")
        table.insert(lines, "Undo:   " .. info.source .. "/scripts/uninstall.sh")
        table.insert(lines, "Update: " .. info.source .. "/scripts/update.sh")
        table.insert(lines, "")
        table.insert(lines, "Keep that folder: the config is a link to it, and your personal files")
        table.insert(lines, "(lua/user/, not in git) live inside it. Save them before deleting or")
        table.insert(lines, "re-cloning it:  :LokiBackup  or  scripts/user-layer.sh export FILE")
    end
    table.insert(lines, "")
    table.insert(lines, "Start here:  :LokiHelp (one-screen guide)   :LokiTutor (practice)")
    table.insert(lines, "Show this again: :LokiInfo     Check your setup: :checkhealth loki")

    return lines
end

local function manual_message()
    return {
        "Welcome to Loki Neovim.",
        "",
        "This config was not set up by scripts/install.sh, so there is no install",
        "record, undo or launcher. It works fine as it is. Two things to know:",
        "",
        "1. Your personal files live in lua/user/ inside this config folder and are",
        "   NOT tracked by git. Deleting or re-cloning the folder deletes them.",
        "   Save them with :LokiBackup (or scripts/user-layer.sh export FILE).",
        "",
        "2. For the safest setup (backup of an old config, undo, safety copies",
        "   before updates) run scripts/install.sh from the repo.",
        "",
        "Start here:  :LokiHelp (guide)   :LokiTutor (practice)   :checkhealth loki",
        "(This notice appears once.)",
    }
end

-- A centered window that sits above other floats (such as lazy.nvim's installer
-- on the very first launch), so it cannot be missed. Close with q, <Esc> or <CR>.
local function show(lines, title)
    local max_width = math.max(20, vim.o.columns - 8)
    local width = 0
    for _, l in ipairs(lines) do
        width = math.max(width, vim.fn.strdisplaywidth(l))
    end
    width = math.min(width + 2, max_width)

    local height = 0
    for _, l in ipairs(lines) do
        height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(l) / width))
    end
    height = math.min(height, math.max(1, vim.o.lines - 6))

    local prev = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
        col = math.max(0, math.floor((vim.o.columns - width) / 2)),
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " " .. (title or "Loki Neovim") .. " ",
        title_pos = "center",
        footer = " q / <Esc> / <CR> to close (j/k to scroll) ",
        footer_pos = "center",
        zindex = 250,
    })
    vim.wo[win].wrap = true
    vim.wo[win].linebreak = true
    vim.wo[win].cursorline = false

    -- Headings (lines that start with an all-caps word) and key/command tokens.
    local ns = vim.api.nvim_create_namespace("loki_help")
    for i, l in ipairs(lines) do
        if l:match("^%u%u%u+") and not l:match("^%u%u%u+%l") then
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { end_col = #l, hl_group = "Title" })
        end
    end
    vim.fn.matchadd("Special", [[<leader>\S\+\|<[CSMA]-\S\+>\|:Loki\w\+\|:Cheatsheet\w*\|:checkhealth \w\+]], 10, -1, { window = win })
    vim.fn.matchadd("Comment", [[^\s*Example:.*$]], 10, -1, { window = win })

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_win_is_valid(prev) then
            vim.api.nvim_set_current_win(prev)
        end
    end
    for _, key in ipairs({ "q", "<Esc>", "<CR>" }) do
        vim.keymap.set("n", key, close, { buffer = buf, nowait = true, desc = "Close" })
    end
end

M.show = show

function M.setup()
    local fresh, shown = paths()

    vim.api.nvim_create_user_command("LokiInfo", function()
        local path = (vim.fn.filereadable(fresh) == 1 and fresh)
            or (vim.fn.filereadable(shown) == 1 and shown)
            or nil
        if not path then
            show(manual_message())
            return
        end
        show(message(read(path)))
    end, { desc = require("util.registry").command_desc("LokiInfo") })

    if vim.fn.filereadable(fresh) == 1 then
        vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = function()
                -- Delay a moment so it lands after lazy.nvim's first-run UI opens.
                vim.defer_fn(function()
                    local ok, info = pcall(read, fresh)
                    if not ok then
                        return
                    end
                    show(message(info))
                    vim.uv.fs_rename(fresh, shown)
                end, 300)
            end,
        })
        return
    end

    -- No install record: cloned by hand. Explain once. Opt out with
    -- vim.g.loki_hide_notices = true in lua/user/options.lua.
    local marker = vim.fn.stdpath("state") .. "/loki-manual-notice-shown"
    if vim.fn.filereadable(shown) == 1 or vim.fn.filereadable(marker) == 1 or vim.g.loki_hide_notices then
        return
    end
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
            vim.defer_fn(function()
                if #vim.api.nvim_list_uis() == 0 then
                    return
                end
                show(manual_message())
                pcall(function()
                    vim.fn.mkdir(vim.fn.fnamemodify(marker, ":h"), "p")
                    vim.fn.writefile({ "1" }, marker)
                end)
            end, 300)
        end,
    })
end

return M
