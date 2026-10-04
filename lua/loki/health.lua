-- :checkhealth loki
local M = {}
local h = vim.health

local function has(name)
    return vim.fn.executable(name) == 1
end

local function check_tool(name, level, advice)
    if has(name) then
        h.ok(name .. " found")
    else
        level(name .. " not found", advice)
    end
end

function M.check()
    h.start("Loki: Neovim")
    local v = vim.version()
    local vs = string.format("%d.%d.%d", v.major, v.minor, v.patch)
    if vim.version.ge(v, { 0, 11, 0 }) then
        h.ok("Neovim " .. vs)
    else
        h.error("Neovim " .. vs .. " is too old", "This config needs Neovim 0.11 or newer.")
    end

    h.start("Loki: install")
    local cfg = vim.fn.stdpath("config")
    local app = vim.env.NVIM_APPNAME
    h.info("Config folder: " .. cfg)
    h.info("App name: " .. ((app and app ~= "") and app or "nvim (default)"))
    local stat = vim.uv.fs_lstat(cfg)
    if stat and stat.type == "link" then
        h.ok("Config is a symlink to " .. (vim.uv.fs_readlink(cfg) or "?"))
    elseif stat then
        h.info("Config is a regular folder (fine if you cloned straight into it)")
    else
        h.error("Config folder not found")
    end
    local state = vim.fn.stdpath("state")
    if vim.fn.filereadable(state .. "/loki-install-info") == 1
        or vim.fn.filereadable(state .. "/loki-install-info.shown") == 1 then
        h.ok("Installed with scripts/install.sh")
    else
        h.warn("No install record: this config was not set up with scripts/install.sh", {
            "It works, but there is no undo, launcher or automatic safety copy of your files.",
            "For the safest setup run scripts/install.sh from the repo folder.",
        })
    end
    h.info("Run :LokiInfo to see how it was installed and where any backup went")
    h.info("Plugin lockfile: " .. require("util.lockfile").path()
        .. (vim.g.loki_lockfile_in_repo and " (tracked in the repo)" or " (personal copy)"))

    h.start("Loki: required tools")
    check_tool("git", h.error, "Needed by lazy.nvim to install plugins.")
    check_tool("make", h.warn, "Needed to build telescope-fzf-native and LuaSnip's jsregexp.")
    if has("cc") or has("gcc") or has("clang") then
        h.ok("C compiler found")
    else
        h.warn("No C compiler found", "Install gcc or clang: needed for Tree-sitter parsers and fzf-native.")
    end
    check_tool("rg", h.warn, "Install ripgrep: needed for <leader>fg (live grep).")
    check_tool("curl", h.warn, "Needed by Mason.")
    check_tool("unzip", h.warn, "Needed by Mason.")
    local ok_cb, cb = pcall(function() return vim.fn["provider#clipboard#Executable"]() end)
    if ok_cb and cb ~= "" then
        h.ok("Clipboard provider: " .. cb)
    else
        h.warn("No clipboard provider found", {
            "This config uses the system clipboard (clipboard=unnamedplus), so yank and paste need a tool.",
            "Install wl-clipboard (Wayland) or xclip (X11), e.g.: sudo dnf install wl-clipboard xclip",
        })
    end

    h.start("Loki: language server toolchains (Mason)")
    check_tool("node", h.warn, "Needed for ts_ls, prettier and other npm-based tools.")
    check_tool("npm", h.warn, "Needed for ts_ls, prettier and other npm-based tools.")
    check_tool("python3", h.warn, "Needed for basedpyright and ruff.")
    if has("go") then
        h.ok("go found")
    else
        h.info("go not found (only needed if you add Go tools such as gopls)")
    end

    h.start("Loki: appearance")
    h.info("A Nerd Font cannot be detected from inside Neovim. If icons show as boxes,")
    h.info("set a Nerd Font as your terminal's font.")

    h.start("Loki: your personal layer (lua/user/)")
    local root = cfg .. "/lua/user"
    local any = false
    for _, f in ipairs({ "options.lua", "keymaps.lua" }) do
        if vim.uv.fs_stat(root .. "/" .. f) then
            h.ok("user/" .. f .. " present")
            any = true
        end
    end
    local plugins = vim.fn.glob(root .. "/plugins/*.lua", false, true)
    if #plugins > 0 then
        h.ok(#plugins .. " user plugin file(s)")
        any = true
    end
    if vim.uv.fs_stat(cfg .. "/lua/config/languages_local.lua") then
        h.ok("config/languages_local.lua present")
        any = true
    end
    if not any then
        h.info("Nothing here yet. :LokiEdit options|keymaps|plugins|languages creates each file,")
        h.info("or see docs/MIGRATING.md and the *.example files in lua/user/")
    end

    h.start("Loki: your keymaps vs shipped keys")
    local kg = require("util.keyguard")
    local over, removed, clashes = kg.overrides_grouped(), kg.removed_grouped(), kg.clashes_grouped()
    if not vim.uv.fs_stat(root .. "/keymaps.lua") then
        h.info("No lua/user/keymaps.lua yet, so nothing to compare.")
    elseif #over + #removed + #clashes == 0 then
        h.ok("None of your keymaps replace, remove or shadow a shipped key")
    end
    for _, o in ipairs(over) do
        local advice = o.plugin
            and { "This plugin sets the key after your keymaps load, so the plugin wins.",
                "Change it through the plugin's opts: docs/MIGRATING.md, section 4." }
            or { "The shipped action still exists as a command: find it with <leader>fc and give it another key,",
                "or delete your mapping to get the shipped key back. <leader>fk shows what a key does now." }
        h.warn(string.format('%s (%s) replaced: was "%s", now "%s"', o.lhs, o.modes, o.was, o.now), advice)
    end
    for _, o in ipairs(removed) do
        h.info(string.format('%s (%s) removed: was "%s"', o.lhs, o.modes, o.was))
    end
    for _, o in ipairs(clashes) do
        h.warn(string.format("%s (%s) waits %d ms before firing because %s also exists",
            o.short, o.modes, vim.o.timeoutlen, o.long),
            "Use a key that is not the start of another key, or accept the short delay.")
    end

    h.start("Loki: safety copies of your personal files")
    local dir = require("util.guide").backup_dir()
    local copies = vim.fn.glob(dir .. "/user-layer-*.tar.gz", false, true)
    table.sort(copies)
    if #copies > 0 then
        local st = vim.uv.fs_stat(copies[#copies])
        local days = st and math.floor((os.time() - st.mtime.sec) / 86400) or 0
        h.ok(#copies .. " safety copy(ies) in " .. dir .. " (newest is " .. days .. " day(s) old)")
    elseif any then
        h.warn("Your personal files exist but no safety copy has been made yet", {
            "Run :LokiBackup now, or scripts/user-layer.sh backup.",
            "scripts/install.sh and scripts/update.sh make one automatically.",
        })
    else
        h.info("Nothing to back up yet.")
    end
    h.info("Another machine: scripts/user-layer.sh export FILE here, import FILE there.")
    h.info("Never delete or re-clone the repo folder before exporting: lua/user/ is not in git.")

    h.start("Loki: language table")
    local lang_problems = require("util.languages").problems()
    if #lang_problems == 0 then
        h.ok("config/languages.lua (and languages_local.lua) look valid")
    else
        for _, p in ipairs(lang_problems) do
            h.warn("Language table: " .. p)
        end
    end
 
    h.start("Loki: extras (opt-in)")
    local extras = require("util.extras")
    local on, unknown = extras.requested()
    if #on == 0 and #unknown == 0 then
        h.info("No extras enabled. :LokiExtras lists them; docs/EXTRAS.md explains how to enable one.")
    end
    for _, name in ipairs(unknown) do
        h.warn("Unknown extra in vim.g.loki_extras: " .. name, "Available: " .. table.concat(extras.order, ", "))
    end
    for _, name in ipairs(on) do
        h.ok(name .. " enabled")
        local fn = extras.registry[name].health
        if fn then
            fn({ h = h, check_tool = check_tool, has = has })
        end
    end
end

return M
