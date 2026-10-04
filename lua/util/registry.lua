-- ONE SOURCE OF TRUTH for keys, commands and help topics.
--
-- Everything the user can read about a shipped key or command comes from here:
--   * config/keymaps.lua and util/extras.lua create the keys from `keys`
--   * util/lsp.lua attaches the LSP keys (buffer-local) from the entries with `lsp`
--   * plugins/textobjects.lua feeds which-key from the same list
--   * util/guide.lua (:LokiHelp), util/helpdoc.lua (doc/loki.txt) and the
--     cheatsheet render `keys`, `commands` and `topics`
--   * scripts/check-help.sh fails when an entry is incomplete or undocumented
--
-- Key entry fields:
--   mode, lhs   string or list (several modes / several keys with the same meaning)
--   rhs         string or function. Omitted when `lsp` or `set = false`
--   opts        extra vim.keymap.set options (expr = true, ...)
--   desc        SHORT text for which-key: what happens and where the result appears
--   long        2 to 4 sentences for :LokiHelp and :help loki (required)
--   example     optional one-liner
--   see         optional "docs/FILE.md#anchor" (the file and anchor must exist)
--   group       docs section (see M.group_topic)
--   doc         how docs/KEYBINDINGS.md writes the key, when not literally `lhs`
--   lsp         name of an action in util/lsp.lua: buffer-local when a server attaches,
--               a friendly notice (global fallback) when none is attached
--   extra       name of the extra that owns the key (only set while enabled)
--   set = false documented only: the key is created by a plugin or by Neovim itself
--   when        function() -> boolean; the key is skipped when it returns false
local M = {}

M.keys = {
    -- ===================================================================
    -- Fundamentals
    -- ===================================================================
    { group = "Fundamentals", mode = "i", lhs = "jk", rhs = "<Esc>", desc = "Exit Insert mode",
      long = "Press j then k quickly in Insert mode to go back to Normal mode without reaching for Escape. "
          .. "Typed slowly, you just get the letters j and k.",
      example = "Type some text, then press jk.", see = "docs/KEYBINDINGS.md#fundamentals" },

    { group = "Fundamentals", mode = { "n", "i", "v" }, lhs = { "<Up>", "<Down>", "<Left>", "<Right>" },
      rhs = "<Nop>", desc = "Arrow key disabled (learn hjkl)", doc = "Arrow keys",
      when = function() return vim.g.loki_disable_arrows ~= false end,
      long = "The arrow keys do nothing on purpose, so that real Vim movement (h j k l, w b e) becomes a habit. "
          .. "Turn the ban off with vim.g.loki_disable_arrows = false in lua/user/options.lua.",
      see = "docs/MIGRATING.md#3-switches-you-can-set" },

    { group = "Fundamentals", mode = "n", lhs = "n", rhs = "nzzzv", desc = "Next search result (centered)",
      long = "Jumps to the next match of the last search and keeps it in the middle of the window. "
          .. "Start a search with / (forward) or ? (backward).",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "n", lhs = "N", rhs = "Nzzzv", desc = "Previous search result (centered)",
      long = "Jumps to the previous match of the last search and keeps it in the middle of the window.",
      see = "docs/KEYBINDINGS.md#fundamentals" },

    { group = "Fundamentals", mode = "n", lhs = "j",
      rhs = function() return vim.v.count == 0 and "gj" or "j" end, opts = { expr = true },
      desc = "Down (display line; with a count, real lines)",
      long = "Moves down one screen line, so long wrapped lines are walked through naturally. "
          .. "With a count (5j) it moves that many real lines, which keeps relative line numbers useful.",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "n", lhs = "k",
      rhs = function() return vim.v.count == 0 and "gk" or "k" end, opts = { expr = true },
      desc = "Up (display line; with a count, real lines)",
      long = "Moves up one screen line. With a count (5k) it moves that many real lines.",
      see = "docs/KEYBINDINGS.md#fundamentals" },

    { group = "Fundamentals", mode = "v", lhs = "<", rhs = "<gv", desc = "Indent left, keep selection",
      long = "Shifts the selected lines left by one shiftwidth and keeps them selected, so you can press < again.",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "v", lhs = ">", rhs = ">gv", desc = "Indent right, keep selection",
      long = "Shifts the selected lines right by one shiftwidth and keeps them selected, so you can press > again.",
      see = "docs/KEYBINDINGS.md#fundamentals" },

    { group = "Fundamentals", mode = "n", lhs = "<Esc>", rhs = "<cmd>nohlsearch<cr>", desc = "Clear search highlight",
      long = "Removes the yellow highlight left by a search. The search itself is kept, so n and N still work.",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "n", lhs = "<C-s>", rhs = "<cmd>write<cr>", desc = "Save file",
      long = "Writes the current buffer to disk. Format on save runs first when it is enabled (see :LokiFormat). "
          .. "In Insert mode <C-s> is Neovim's signature help instead.",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "n", lhs = "<leader>q", rhs = "<cmd>quit<cr>", desc = "Quit window",
      long = "Closes the current window; the last window quits Neovim. "
          .. "With unsaved changes Neovim asks what to do instead of failing.",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "n", lhs = "<C-d>", rhs = "<C-d>zz", desc = "Half page down, centered",
      long = "Scrolls half a screen down and centers the cursor line, so you do not lose your place.",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "n", lhs = "<C-u>", rhs = "<C-u>zz", desc = "Half page up, centered",
      long = "Scrolls half a screen up and centers the cursor line.",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "v", lhs = "J", rhs = ":m '>+1<CR>gv=gv", desc = "Move selected lines down",
      long = "Moves the selected lines one line down and re-indents them. The selection stays active.",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "v", lhs = "K", rhs = ":m '<-2<CR>gv=gv", desc = "Move selected lines up",
      long = "Moves the selected lines one line up and re-indents them. The selection stays active.",
      see = "docs/KEYBINDINGS.md#fundamentals" },
    { group = "Fundamentals", mode = "x", lhs = "p", rhs = [["_dP]], desc = "Paste over selection, keep register",
      long = "Pastes over the selected text without replacing what you yanked, so you can paste the same text again. "
          .. "The replaced text is discarded (it goes to the black-hole register).",
      see = "docs/KEYBINDINGS.md#fundamentals" },

    -- ===================================================================
    -- Windows and buffers
    -- ===================================================================
    { group = "Windows", mode = "n", lhs = "<C-h>", rhs = "<C-w>h", desc = "Focus left window", doc = "<C-h/j/k/l>",
      long = "Moves the cursor to the window on the left. <C-j>, <C-k> and <C-l> do the same for down, up and right. "
          .. "In a terminal that sends Backspace as <C-h>, Backspace will also move windows in Normal mode.",
      see = "docs/KEYBINDINGS.md#windows-and-buffers" },
    { group = "Windows", mode = "n", lhs = "<C-j>", rhs = "<C-w>j", desc = "Focus lower window", doc = "<C-h/j/k/l>",
      long = "Moves the cursor to the window below.", see = "docs/KEYBINDINGS.md#windows-and-buffers" },
    { group = "Windows", mode = "n", lhs = "<C-k>", rhs = "<C-w>k", desc = "Focus upper window", doc = "<C-h/j/k/l>",
      long = "Moves the cursor to the window above.", see = "docs/KEYBINDINGS.md#windows-and-buffers" },
    { group = "Windows", mode = "n", lhs = "<C-l>", rhs = "<C-w>l", desc = "Focus right window", doc = "<C-h/j/k/l>",
      long = "Moves the cursor to the window on the right.", see = "docs/KEYBINDINGS.md#windows-and-buffers" },
    { group = "Windows", mode = "n", lhs = "<leader>ww", rhs = "<C-w>w", desc = "Cycle to the next window",
      long = "Jumps to the next window in order, wrapping around at the end.",
      see = "docs/KEYBINDINGS.md#windows-and-buffers" },
    { group = "Windows", mode = "n", lhs = "<leader>wd", rhs = "<C-w>c", desc = "Close this window",
      long = "Closes the current window. The buffer stays loaded (use <leader>bd to remove it).",
      see = "docs/KEYBINDINGS.md#windows-and-buffers" },
    { group = "Windows", mode = "n", lhs = "<leader>wv", rhs = "<C-w>v", desc = "Split window vertically",
      long = "Splits the window into two side by side, showing the same buffer in both.",
      see = "docs/KEYBINDINGS.md#windows-and-buffers" },
    { group = "Windows", mode = "n", lhs = "<leader>ws", rhs = "<C-w>s", desc = "Split window horizontally",
      long = "Splits the window into two, one above the other, showing the same buffer in both.",
      see = "docs/KEYBINDINGS.md#windows-and-buffers" },

    { group = "Buffers", mode = "n", lhs = "H", rhs = "<cmd>bprevious<cr>", desc = "Previous buffer",
      long = "Switches to the previous open file. The open buffers are shown along the top of the screen.",
      see = "docs/KEYBINDINGS.md#windows-and-buffers" },
    { group = "Buffers", mode = "n", lhs = "L", rhs = "<cmd>bnext<cr>", desc = "Next buffer",
      long = "Switches to the next open file. The open buffers are shown along the top of the screen.",
      see = "docs/KEYBINDINGS.md#windows-and-buffers" },
    { group = "Buffers", mode = "n", lhs = "<leader>bd", rhs = "<cmd>bdelete<cr>", desc = "Close this buffer (file)",
      long = "Removes the current buffer from the list of open files. Windows showing it switch to another buffer.",
      see = "docs/KEYBINDINGS.md#windows-and-buffers" },

    -- ===================================================================
    -- LSP (buffer-local when a server attaches; friendly notice otherwise)
    -- ===================================================================
    { group = "LSP", mode = "n", lhs = "K", lsp = "hover", desc = "Hover: show docs for the symbol under the cursor",
      long = "Opens a floating window with the documentation and type of the symbol under the cursor. "
          .. "Press K again to enter the window and scroll it; <Esc> or moving away closes it.",
      example = "Put the cursor on a function name and press K.", see = "docs/LSP.md" },
    { group = "LSP", mode = "n", lhs = "gd", lsp = "definition", desc = "Go to definition (<C-o> jumps back)",
      long = "Jumps to where the symbol under the cursor is defined, even in another file. "
          .. "<C-o> goes back to where you were and <C-i> forward again.",
      see = "docs/LSP.md" },
    { group = "LSP", mode = "n", lhs = "gD", lsp = "declaration", desc = "Go to declaration",
      long = "Jumps to the declaration of the symbol (in C and C++ this is usually the header). "
          .. "Many servers treat it the same as gd.",
      see = "docs/LSP.md" },
    { group = "LSP", mode = "n", lhs = "gi", lsp = "implementation", desc = "Go to implementation",
      long = "Jumps to the implementation of an interface or abstract method. When there are several, a list opens.",
      see = "docs/LSP.md" },
    { group = "LSP", mode = "n", lhs = "gr", lsp = "references", desc = "References: list every use of the symbol",
      long = "Lists every place the symbol is used in the quickfix window. Move with j/k and press Enter to jump. "
          .. "A lone gr waits 400 ms because Neovim also has grr, gra and grn.",
      see = "docs/LSP.md" },
    { group = "LSP", mode = "n", lhs = "<leader>rn", lsp = "rename", desc = "Rename symbol everywhere (asks for the new name)",
      long = "Prompts for a new name and renames the symbol in every file of the project. "
          .. "Use :wa afterwards to save all the files that changed.",
      see = "docs/LSP.md" },
    { group = "LSP", mode = { "n", "v" }, lhs = "<leader>ca", lsp = "code_action", desc = "Code action: pick a quick fix or refactor",
      long = "Opens a menu of fixes and refactors the server offers at the cursor, such as adding an import. "
          .. "Select with Enter.",
      see = "docs/LSP.md" },
    { group = "LSP", mode = "n", lhs = "<leader>D", lsp = "type_definition", desc = "Go to type definition",
      long = "Jumps to the definition of the type of the symbol under the cursor, not of the symbol itself.",
      see = "docs/LSP.md" },
    { group = "LSP", mode = "n", lhs = "<leader>ds", lsp = "document_symbol", desc = "Symbols in this file (location list)",
      long = "Fills the location list with the functions, classes and variables of this file. "
          .. "For a searchable picker use <leader>fs instead.",
      see = "docs/LSP.md" },
    { group = "LSP", mode = "n", lhs = "<leader>ih", lsp = "inlay_hints", desc = "Toggle inlay hints (inline types and parameter names)",
      long = "Shows or hides the small hints that servers draw inside the code, such as parameter names. "
          .. "Not every server provides them.",
      see = "docs/LSP.md" },

    -- ===================================================================
    -- Diagnostics
    -- ===================================================================
    { group = "Diagnostics", mode = "n", lhs = "[d",
      rhs = function() vim.diagnostic.jump({ count = -1, float = true }) end,
      desc = "Previous diagnostic (opens its message)",
      long = "Jumps to the previous error or warning in this buffer and shows its message in a float.",
      see = "docs/LSP.md#diagnostics" },
    { group = "Diagnostics", mode = "n", lhs = "]d",
      rhs = function() vim.diagnostic.jump({ count = 1, float = true }) end,
      desc = "Next diagnostic (opens its message)",
      long = "Jumps to the next error or warning in this buffer and shows its message in a float.",
      see = "docs/LSP.md#diagnostics" },
    { group = "Diagnostics", mode = "n", lhs = "<leader>de", rhs = vim.diagnostic.open_float,
      desc = "Show the diagnostic message at the cursor",
      long = "Opens a float with the full text of the error or warning on the cursor line.",
      see = "docs/LSP.md#diagnostics" },
    { group = "Diagnostics", mode = "n", lhs = "<leader>dq", rhs = vim.diagnostic.setqflist,
      desc = "Send all diagnostics to the quickfix list",
      long = "Collects every diagnostic of every open buffer into the quickfix list and opens it. "
          .. "Walk it with :cnext and :cprev.",
      see = "docs/LSP.md#diagnostics" },
    { group = "Diagnostics", mode = "n", lhs = "<leader>xx", rhs = "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics panel: all files (toggle)",
      long = "Opens or closes the Trouble panel listing the problems of all open files. "
          .. "Inside it press ? for its keys, Enter to jump and q to close.",
      see = "docs/PLUGIN_KEYS.md#trouble" },
    { group = "Diagnostics", mode = "n", lhs = "<leader>xX", rhs = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Diagnostics panel: this buffer only (toggle)",
      long = "Like <leader>xx but only lists the problems of the current file.",
      see = "docs/PLUGIN_KEYS.md#trouble" },

    -- ===================================================================
    -- Find (Telescope)
    -- ===================================================================
    { group = "Find", mode = "n", lhs = "<leader>ff", rhs = "<cmd>Telescope find_files<cr>", desc = "Find files by name (fuzzy)",
      long = "Opens a picker over every file in the project. Type part of the name, move with <C-j>/<C-k>, Enter opens it.",
      example = "<leader>ff, type 'lsp', Enter.", see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fg", rhs = "<cmd>Telescope live_grep<cr>", desc = "Search text in the project (needs ripgrep)",
      long = "Searches the contents of all files as you type. It needs ripgrep (rg); :checkhealth loki tells you if it is missing.",
      see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fb", rhs = "<cmd>Telescope buffers<cr>", desc = "Pick an open buffer",
      long = "Lists the open files. Handy when there are more of them than fit in the tabline.",
      see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fh", rhs = "<cmd>Telescope help_tags<cr>", desc = "Search Neovim help (try: loki)",
      long = "Fuzzy-searches every help tag, including this config's own :help loki pages.",
      example = "<leader>fh, type 'loki'.", see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fr", rhs = "<cmd>Telescope oldfiles<cr>", desc = "Recent files",
      long = "Lists the files you opened recently, newest first.", see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fc", rhs = "<cmd>Telescope commands<cr>", desc = "Find and run a command",
      long = "Searches all : commands, including the Loki ones. Enter runs the selected command.",
      see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fk", rhs = "<cmd>Telescope keymaps<cr>", desc = "Search all keymaps",
      long = "Searches every key mapping with its description. Use it to find out what a key does or which key does something.",
      see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fC", rhs = "<cmd>Cheatsheet<cr>", desc = "Open the generated cheatsheet",
      long = "Regenerates and opens the cheatsheet built from the running editor, including your own keys.",
      see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fi", rhs = "<cmd>LokiHelp<cr>", desc = "Loki guide: what you can do",
      long = "Opens the one-screen guide. Add a topic for details, for example :LokiHelp lsp.",
      see = "docs/GETTING_STARTED.md" },
    { group = "Find", mode = "n", lhs = "<leader>fs", rhs = "<cmd>Telescope lsp_document_symbols<cr>",
      desc = "Symbols in this file (searchable)",
      long = "Lists the functions, classes and variables of the current file and jumps to the one you pick. Needs a language server.",
      see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fS", rhs = "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
      desc = "Symbols in the whole project (type to search)",
      long = "Searches symbol names across the whole project; the list updates as you type. Needs a language server.",
      see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fd", rhs = "<cmd>Telescope diagnostics<cr>",
      desc = "Diagnostics of open files (searchable)",
      long = "Lists errors and warnings of all open buffers in a picker. For a persistent panel use <leader>xx.",
      see = "docs/FINDING.md" },
    { group = "Find", mode = "n", lhs = "<leader>fG", rhs = "<cmd>Telescope git_status<cr>",
      desc = "Changed files in git (with a diff preview)",
      long = "Lists the files git sees as changed, with a preview of each diff. Needs the folder to be a git repository.",
      see = "docs/GIT.md" },
    { group = "Find", mode = "n", lhs = "<leader>?", rhs = function() require("which-key").show({ global = true }) end,
      desc = "Show all keybindings",
      long = "Opens the which-key popup with every global key, grouped by prefix.",
      see = "docs/FINDING.md" },

    -- ===================================================================
    -- Explorer and formatting
    -- ===================================================================
    { group = "Explorer", mode = "n", lhs = "<leader>e", rhs = "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer",
      long = "Opens or closes the file tree on the left. Inside it press g? for its own key list.",
      see = "docs/FILES.md" },
    { group = "Explorer", mode = "n", lhs = "<leader>E", rhs = "<cmd>NvimTreeFindFile<cr>", desc = "Reveal current file in the explorer",
      long = "Opens the file tree and moves its cursor to the file you are editing.", see = "docs/FILES.md" },
    { group = "Explorer", mode = { "n", "v" }, lhs = "<leader>cf",
      rhs = function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      desc = "Format file/selection",
      long = "Formats the whole file or the selection with the formatter of the language, or the language server when there is none. "
          .. "Saving also formats, unless :LokiFormat off.",
      see = "docs/LSP.md#formatting" },

    -- ===================================================================
    -- Git (gitsigns)
    -- ===================================================================
    { group = "Git", mode = "n", lhs = "]h", rhs = function() require("gitsigns").next_hunk() end, desc = "Next git hunk",
      long = "Jumps to the next changed block (hunk) in this file, as marked in the sign column.", see = "docs/GIT.md" },
    { group = "Git", mode = "n", lhs = "[h", rhs = function() require("gitsigns").prev_hunk() end, desc = "Previous git hunk",
      long = "Jumps to the previous changed block (hunk) in this file.", see = "docs/GIT.md" },
    { group = "Git", mode = { "n", "v" }, lhs = "<leader>hs",
      rhs = function()
          local gs = require("gitsigns")
          if vim.fn.mode():match("[vV\22]") then
              gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          else
              gs.stage_hunk()
          end
      end,
      desc = "Stage hunk (in Visual mode: only the selected lines)",
      long = "Stages the hunk under the cursor for the next commit. In Visual mode only the selected lines are staged.",
      see = "docs/GIT.md" },
    { group = "Git", mode = { "n", "v" }, lhs = "<leader>hr",
      rhs = function()
          local gs = require("gitsigns")
          if vim.fn.mode():match("[vV\22]") then
              gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          else
              gs.reset_hunk()
          end
      end,
      desc = "Reset hunk: discard changes (in Visual mode: only the selected lines)",
      long = "Throws away the uncommitted change in the hunk, restoring the committed text. "
          .. "In Visual mode only the selected lines are reset. u undoes it.",
      see = "docs/GIT.md" },
    { group = "Git", mode = "n", lhs = "<leader>hu", rhs = function() require("gitsigns").undo_stage_hunk() end,
      desc = "Undo the last stage of a hunk",
      long = "Unstages the hunk you staged last with <leader>hs.", see = "docs/GIT.md" },
    { group = "Git", mode = "n", lhs = "<leader>hp", rhs = function() require("gitsigns").preview_hunk() end, desc = "Preview hunk (floating diff)",
      long = "Shows the old and new text of the hunk under the cursor in a float.", see = "docs/GIT.md" },
    { group = "Git", mode = "n", lhs = "<leader>hb", rhs = function() require("gitsigns").blame_line({ full = true }) end,
      desc = "Blame: who changed this line (full commit message)",
      long = "Shows the author, date and message of the commit that last changed the cursor line.", see = "docs/GIT.md" },
    { group = "Git", mode = "n", lhs = "<leader>hB", rhs = function() require("gitsigns").toggle_current_line_blame() end,
      desc = "Toggle blame text at the end of the cursor line",
      long = "Shows or hides a faded 'author, date, summary' at the end of the current line, following the cursor.",
      see = "docs/GIT.md" },
    { group = "Git", mode = "n", lhs = "<leader>hd", rhs = function() require("gitsigns").diffthis() end,
      desc = "Diff this file against the index (side by side)",
      long = "Opens a side-by-side diff of the file against what is staged. Close the extra window with :q.",
      see = "docs/GIT.md" },

    -- ===================================================================
    -- Documented only: keys that plugins or Neovim create (set = false)
    -- ===================================================================
    { group = "Completion", set = false, mode = "i", lhs = "<C-Space>", desc = "Open the completion menu",
      long = "Forces the completion menu open even before you type. Completion also opens by itself while you type.",
      see = "docs/COMPLETION.md" },
    { group = "Completion", set = false, mode = "i", lhs = "<C-j>", desc = "Next completion item", doc = "<C-j>` / `<C-k>",
      long = "Selects the next item of the open completion menu. Nothing is preselected until you move.",
      see = "docs/COMPLETION.md" },
    { group = "Completion", set = false, mode = "i", lhs = "<C-k>", desc = "Previous completion item", doc = "<C-j>` / `<C-k>",
      long = "Selects the previous item of the open completion menu.", see = "docs/COMPLETION.md" },
    { group = "Completion", set = false, mode = { "i", "s" }, lhs = "<Tab>", desc = "Next item, or jump to the next snippet field", doc = "<Tab>` / `<S-Tab>",
      long = "With the menu open it selects the next item. Inside an expanded snippet it jumps to the next field; otherwise it inserts a Tab.",
      see = "docs/COMPLETION.md" },
    { group = "Completion", set = false, mode = { "i", "s" }, lhs = "<S-Tab>", desc = "Previous item, or jump back in a snippet", doc = "<Tab>` / `<S-Tab>",
      long = "With the menu open it selects the previous item. Inside a snippet it jumps to the previous field.",
      see = "docs/COMPLETION.md" },
    { group = "Completion", set = false, mode = "i", lhs = "<CR>", desc = "Accept the selected completion item",
      long = "Inserts the selected item. If nothing is selected, Enter just starts a new line.", see = "docs/COMPLETION.md" },
    { group = "Completion", set = false, mode = "i", lhs = "<C-e>", desc = "Close the completion menu",
      long = "Closes the menu and keeps what you typed.", see = "docs/COMPLETION.md" },
    { group = "Completion", set = false, mode = "i", lhs = "<C-d>", desc = "Scroll completion docs up", doc = "<C-d>` / `<C-f>",
      long = "Scrolls the documentation window next to the menu up. <C-f> scrolls it down.", see = "docs/COMPLETION.md" },

    { group = "Terminal", set = false, mode = { "n", "i", "t" }, lhs = [[<C-\>]], desc = "Toggle the bottom terminal",
      long = "Opens or hides the terminal at the bottom, from any mode. A count picks a numbered terminal: 2<C-\\> opens terminal 2. "
          .. ":TermSelect picks one from a list.",
      see = "docs/TERMINAL.md" },
    { group = "Terminal", set = false, mode = "t", lhs = "jk", desc = "Terminal: back to Normal mode",
      long = "In the toggleterm terminal only: leaves Terminal mode so you can scroll and search the output. Press i to type again.",
      see = "docs/TERMINAL.md" },
    { group = "Terminal", set = false, mode = "t", lhs = "<Esc>", desc = "Terminal: back to Normal mode",
      long = "Same as jk, for the toggleterm terminal only. Other terminals (lazygit, fzf, vim) keep Esc for their program.",
      see = "docs/TERMINAL.md" },
    { group = "Terminal", set = false, mode = "t", lhs = "<C-h>", desc = "Terminal: focus left window", doc = "<C-h/j/k/l>",
      long = "Leaves the terminal and moves to the window on the left. <C-j>, <C-k>, <C-l> do the same for the other directions.",
      see = "docs/TERMINAL.md" },
    { group = "Terminal", set = false, mode = "t", lhs = "<C-j>", desc = "Terminal: focus lower window", doc = "<C-h/j/k/l>",
      long = "Leaves the terminal and moves to the window below.", see = "docs/TERMINAL.md" },
    { group = "Terminal", set = false, mode = "t", lhs = "<C-k>", desc = "Terminal: focus upper window", doc = "<C-h/j/k/l>",
      long = "Leaves the terminal and moves to the window above.", see = "docs/TERMINAL.md" },
    { group = "Terminal", set = false, mode = "t", lhs = "<C-l>", desc = "Terminal: focus right window", doc = "<C-h/j/k/l>",
      long = "Leaves the terminal and moves to the window on the right.", see = "docs/TERMINAL.md" },

    { group = "Editing", set = false, mode = { "n", "x" }, lhs = "gc", desc = "Comment: toggle with a motion or selection",
      long = "Neovim's built-in commenting. gc followed by a motion comments that range (gcap: a paragraph); in Visual mode gc comments the selection.",
      see = "docs/KEYBINDINGS.md#text-objects-and-editing" },
    { group = "Editing", set = false, mode = "n", lhs = "gcc", desc = "Comment: toggle the current line",
      long = "Comments or uncomments the current line; 3gcc does three lines.", see = "docs/KEYBINDINGS.md#text-objects-and-editing" },
    { group = "Editing", set = false, mode = { "o", "x" }, lhs = "a", desc = "Around a text object (mini.ai)", doc = "`a`/`i",
      long = "After an operator (d, c, y, v) a<key> selects the object plus its surroundings and i<key> only what is inside: "
          .. "ib is inside brackets, aq around any quotes, if inside a function call, ia an argument.",
      example = "daq deletes a quoted string with its quotes; cia changes one argument.",
      see = "docs/KEYBINDINGS.md#text-objects-and-editing" },

    -- ===================================================================
    -- Extras (only while the extra is enabled in vim.g.loki_extras)
    -- ===================================================================
    { extra = "sessions", group = "Sessions", mode = "n", lhs = "<leader>ss", rhs = function() require("persistence").load() end,
      desc = "Restore session for this folder",
      long = "Reopens the files and splits you had in this folder (and git branch) the last time you quit. Never happens by itself.",
      see = "docs/EXTRAS.md#sessions" },
    { extra = "sessions", group = "Sessions", mode = "n", lhs = "<leader>sl", rhs = function() require("persistence").load({ last = true }) end,
      desc = "Restore last session",
      long = "Restores the most recent session of any folder.", see = "docs/EXTRAS.md#sessions" },
    { extra = "sessions", group = "Sessions", mode = "n", lhs = "<leader>sd", rhs = function() require("persistence").stop() end,
      desc = "Do not save this session",
      long = "Stops recording, so quitting does not overwrite the saved session of this folder.", see = "docs/EXTRAS.md#sessions" },
    { extra = "docker", group = "Clients", mode = "n", lhs = "<leader>kk", rhs = function() require("util.extras").tui("lazydocker") end,
      desc = "Docker (lazydocker in a floating terminal)",
      long = "Opens lazydocker in a floating terminal. It needs docker and lazydocker installed; otherwise you get a message.",
      see = "docs/EXTRAS.md#docker" },
    { extra = "database", group = "Clients", mode = "n", lhs = "<leader>kd", rhs = "<cmd>DBUIToggle<cr>",
      desc = "Database UI (toggle)",
      long = "Opens or closes the vim-dadbod database sidebar. Press A inside it to add a connection; keep passwords in environment variables.",
      see = "docs/EXTRAS.md#database" },
    { extra = "rest", group = "Clients", mode = "n", lhs = "<leader>kr", rhs = function() require("util.rest").run() end,
      desc = "Run the HTTP request under the cursor",
      long = "In a .http file, sends the block under the cursor (between ### lines) with curl and shows the response in a split.",
      see = "docs/EXTRAS.md#rest" },
    { extra = "dap", group = "Debug", mode = "n", lhs = "<leader>tb", rhs = function() require("dap").toggle_breakpoint() end,
      desc = "Toggle breakpoint", doc = "<leader>tb` / `<F9>",
      long = "Sets or removes a breakpoint on the cursor line.", see = "docs/EXTRAS.md#dap" },
    { extra = "dap", group = "Debug", mode = "n", lhs = "<leader>tc", rhs = function() require("dap").continue() end,
      desc = "Debug: start / continue", doc = "<leader>tc` / `<F5>",
      long = "Starts a debug session (choosing a configuration if needed) or continues to the next breakpoint.", see = "docs/EXTRAS.md#dap" },
    { extra = "dap", group = "Debug", mode = "n", lhs = "<leader>tu", rhs = function() require("dapui").toggle() end,
      desc = "Toggle debug UI",
      long = "Shows or hides the variables, stack and console panels.", see = "docs/EXTRAS.md#dap" },
    { extra = "dap", group = "Debug", mode = "n", lhs = "<leader>tx", rhs = function() require("dap").terminate() end,
      desc = "Debug: stop",
      long = "Ends the debug session and closes the debug UI.", see = "docs/EXTRAS.md#dap" },
    { extra = "dap", group = "Debug", mode = "n", lhs = "<F5>", rhs = function() require("dap").continue() end,
      desc = "Debug: start / continue", doc = "<leader>tc` / `<F5>",
      long = "Same as <leader>tc. Some terminals intercept F-keys; the <leader>t keys always work.", see = "docs/EXTRAS.md#dap" },
    { extra = "dap", group = "Debug", mode = "n", lhs = "<F9>", rhs = function() require("dap").toggle_breakpoint() end,
      desc = "Toggle breakpoint", doc = "<leader>tb` / `<F9>",
      long = "Same as <leader>tb: sets or removes a breakpoint on the cursor line.", see = "docs/EXTRAS.md#dap" },
    { extra = "dap", group = "Debug", mode = "n", lhs = "<F10>", rhs = function() require("dap").step_over() end,
      desc = "Debug: step over",
      long = "Runs the current line without entering function calls.", see = "docs/EXTRAS.md#dap" },
    { extra = "dap", group = "Debug", mode = "n", lhs = "<F11>", rhs = function() require("dap").step_into() end,
      desc = "Debug: step into",
      long = "Steps into the function call on the current line.", see = "docs/EXTRAS.md#dap" },
    { extra = "dap", group = "Debug", mode = "n", lhs = "<S-F11>", rhs = function() require("dap").step_out() end,
      desc = "Debug: step out",
      long = "Runs until the current function returns.", see = "docs/EXTRAS.md#dap" },
    { extra = "lint", group = "Code", mode = "n", lhs = "<leader>cl", rhs = function() require("lint").try_lint() end,
      desc = "Lint this buffer now",
      long = "Runs the linters configured for this filetype and shows the result as diagnostics. Linting also runs on save.",
      see = "docs/EXTRAS.md#lint" },
    { extra = "surround", group = "Surround", set = false, mode = "n", lhs = "gsa", desc = "Surround: add around a motion",
      long = "gsa followed by a motion and a character wraps the text: gsaiw) puts parentheses around the word. In Visual mode gsa wraps the selection.",
      example = "gsaiw\" wraps the word in double quotes.", see = "docs/EXTRAS.md#surround" },
    { extra = "surround", group = "Surround", set = false, mode = "n", lhs = "gsd", desc = "Surround: delete the surrounding character",
      long = "gsd followed by the character removes it: gsd\" removes the quotes around the cursor.", see = "docs/EXTRAS.md#surround" },
    { extra = "surround", group = "Surround", set = false, mode = "n", lhs = "gsr", desc = "Surround: replace the surrounding character",
      long = "gsr followed by the old and the new character: gsr\"' changes double quotes to single quotes.", see = "docs/EXTRAS.md#surround" },
}

-- Which :LokiHelp topic and docs section each key group belongs to.
M.group_topic = {
    Fundamentals = "keys", Windows = "keys", Buffers = "keys", Editing = "keys",
    LSP = "lsp", Diagnostics = "lsp", Completion = "lsp",
    Find = "files", Explorer = "files",
    Git = "git", Terminal = "terminal",
    Sessions = "extras", Clients = "extras", Debug = "extras", Code = "extras", Surround = "extras",
}

-- ===========================================================================
-- Commands
-- ===========================================================================
M.commands = {
    { name = "LokiHelp", args = "[topic]", desc = "One-screen guide, or a topic: keys, lsp, git, files, languages, extras, terminal, troubleshooting",
      long = "Without an argument it shows the overview. With a topic it shows the keys, commands and fixes for that area. "
          .. "Tab completes the topic names. The same text is available offline as :help loki.",
      example = ":LokiHelp lsp", see = "docs/GETTING_STARTED.md" },
    { name = "LokiTutor", desc = "Short practice tutorial for this config",
      long = "Opens a scratch buffer with a ten-minute tutorial. Nothing you type in it is saved.",
      see = "docs/GETTING_STARTED.md" },
    { name = "LokiEdit", args = "{options|keymaps|plugins|languages}", desc = "Create/open your personal file: options, keymaps, plugins, languages",
      long = "Creates the file in lua/user/ (or languages_local.lua) from its example and opens it. Your files are not in git, so run :LokiBackup now and then.",
      example = ":LokiEdit keymaps", see = "docs/MIGRATING.md#1-your-personal-layer" },
    { name = "LokiExtras", desc = "List opt-in extras and which are enabled",
      long = "Shows every extra with an [x] when it is enabled. Enable one in lua/user/options.lua with vim.g.loki_extras.",
      see = "docs/EXTRAS.md" },
    { name = "LokiFormat", args = "[on|off|status]", desc = "Turn format on save on or off for this session",
      long = "Switches automatic formatting when you save. It only lasts until you quit; <leader>cf always formats on demand.",
      example = ":LokiFormat off", see = "docs/LSP.md#formatting" },
    { name = "LokiBackup", args = "[file]", desc = "Export your personal files to an archive (default: ~/loki-user-layer-<date>.tar.gz)",
      long = "Packs lua/user/ and languages_local.lua into a .tar.gz, because those files are not in git. "
          .. "Restore on any machine with scripts/user-layer.sh import FILE.",
      see = "docs/MIGRATING.md#5-keeping-your-layer-safe-and-portable" },
    { name = "LokiInfo", desc = "Show how Loki Neovim was installed",
      long = "Shows the install mode, where your old config was backed up, and how to update or undo.",
      see = "docs/INSTALL.md" },
    { name = "LokiLockReset", desc = "Adopt the plugin versions shipped with the config",
      long = "Replaces your personal plugin lockfile with the shipped one. Restart Neovim and run :Lazy restore to apply it.",
      see = "docs/INSTALL.md#8-plugin-versions-the-lockfile" },
    { name = "LokiKeys", desc = "Show shipped keys your keymaps replace",
      long = "Lists shipped keys that your lua/user/keymaps.lua replaced, removed or delays through a prefix clash.",
      see = "docs/MIGRATING.md#before-you-override-a-key" },
    { name = "LokiDocs", desc = "Browse the docs/ folder with Telescope",
      long = "Opens a Telescope picker over the markdown docs shipped with the config; Enter opens one in a buffer.",
      see = "docs/README.md" },
    { name = "LokiLsp", desc = "Language support for this buffer: server, root, formatter, parser, and what to do if one is missing",
      long = "One screen that explains why completion, go-to-definition or formatting does or does not work in the current file.",
      see = "docs/LSP.md" },
    { name = "LokiRest", extra = "rest", desc = "Run the HTTP request under the cursor (.http file)",
      long = "Same as <leader>kr. Sends the request block under the cursor with curl.", see = "docs/EXTRAS.md#rest" },
    { name = "Cheatsheet", desc = "Open live Neovim cheatsheet",
      long = "Regenerates the cheatsheet from the running editor and opens it.", see = "docs/ENVIRONMENT_GUIDE.md#7-cheatsheet-automation" },
    { name = "CheatsheetUpdate", desc = "Regenerate live Neovim cheatsheet",
      long = "Regenerates the cheatsheet file without opening it.", see = "docs/ENVIRONMENT_GUIDE.md#7-cheatsheet-automation" },
}

-- ===========================================================================
-- Help topics (:LokiHelp <topic>, doc/loki.txt)
-- ===========================================================================
M.topics = {
    keys = {
        title = "Keys and the key popup", tag = "loki-keys",
        intro = {
            "Leader is the Space bar. Press a key that starts a sequence (<leader>, g, z, [, ], <C-w>, or an operator such as d, y, c) and wait a moment:",
            "a popup lists what can follow, each with a description. Type the next key to go deeper; <BS> goes up one level, <Esc> closes it.",
            "After d, y or c the popup lists motions and text objects (type i or a to see inner/around objects such as quotes, brackets, arguments).",
            "<leader>? shows every key, <leader>fk searches them by description.",
        },
        groups = { "Fundamentals", "Windows", "Buffers", "Editing" },
        see = "docs/KEYBINDINGS.md",
        fail = {
            "No popup appears: run :checkhealth which-key. Your terminal may also swallow the key.",
            "A key does nothing or does something else: <leader>fk shows what it is mapped to; :LokiKeys lists shipped keys your own keymaps replaced.",
        },
    },
    lsp = {
        title = "Code intelligence (LSP), diagnostics and completion", tag = "loki-lsp",
        intro = {
            "A language server gives go-to-definition, references, rename, hover docs, completion and diagnostics.",
            "The LSP keys exist only in buffers where a server is attached. Elsewhere they print a notice, and :LokiLsp explains why nothing is attached.",
            "Servers come from the language table (see :LokiHelp languages); Mason installs them.",
        },
        groups = { "LSP", "Diagnostics", "Completion" },
        commands = { "LokiLsp", "LokiFormat" },
        see = "docs/LSP.md",
        fail = {
            "Run :LokiLsp first: it names the server, its root and what is missing.",
            ":Mason shows installed servers (a check mark); :MasonLog shows install errors; :checkhealth vim.lsp lists attached clients.",
            "Mason needs Node.js, Python 3 and sometimes Go: :checkhealth loki lists missing toolchains.",
        },
    },
    git = {
        title = "Git", tag = "loki-git",
        intro = {
            "Gitsigns marks changed lines in the sign column. A hunk is one contiguous block of changes.",
            "Stage, reset, preview and blame hunks without leaving the file. In Visual mode, stage or reset only the selected lines.",
        },
        groups = { "Git" },
        see = "docs/GIT.md",
        fail = {
            "No signs: the file must be inside a git repository and be tracked or new.",
            "Blame is empty on a new file: it has no commit yet.",
        },
    },
    files = {
        title = "Finding and opening files", tag = "loki-files",
        intro = {
            "Telescope is the fuzzy finder behind the <leader>f keys. Inside a picker: <C-j>/<C-k> move, Enter opens, <C-x>/<C-v> open in a split, <C-q> sends results to the quickfix list, ? or <C-/> lists its keys.",
            "The file tree (<leader>e) has its own keys; press g? inside it.",
        },
        groups = { "Find", "Explorer" },
        commands = { "LokiDocs" },
        see = "docs/FINDING.md",
        fail = {
            "<leader>fg does nothing: install ripgrep (rg).",
            "Icons show as boxes: use a Nerd Font in your terminal.",
        },
    },
    languages = {
        title = "Adding and changing languages", tag = "loki-languages",
        intro = {
            "Nothing is installed unless a language is listed. One line in lua/config/languages_local.lua (:LokiEdit languages) gives a language its server, tree-sitter parser, formatter, linter and tools.",
            "Example:  go = { lsp = \"gopls\", parser = \"go\", formatter = \"gofumpt\", tools = { \"gofumpt\" } },",
            "Restart Neovim afterwards and watch :Mason. Disable a default with  rust = false,",
            "Three naming systems: lsp uses lspconfig names (ts_ls), formatter and linter use Conform / nvim-lint names, tools uses Mason package names.",
        },
        commands = { "LokiEdit", "LokiLsp" },
        see = "docs/ADDING_LANGUAGES.md",
        fail = {
            ":checkhealth loki validates the language table and names typos.",
            "Server missing in :Mason: wrong lspconfig name, or Node/Python/Go is missing.",
        },
    },
    extras = {
        title = "Extras (opt-in features)", tag = "loki-extras",
        intro = {
            "Heavier features are off until you enable them in lua/user/options.lua, then restart:",
            "  vim.g.loki_extras = { \"sessions\", \"dashboard\", \"dap\" }",
            ":LokiExtras lists them: sessions, dashboard, docker, database, rest, dap, lint, surround.",
            "Keys below exist only while their extra is enabled.",
        },
        groups = { "Sessions", "Clients", "Debug", "Code", "Surround" },
        commands = { "LokiExtras", "LokiRest" },
        see = "docs/EXTRAS.md",
        fail = {
            ":checkhealth loki lists the external tools an enabled extra is missing (always a warning).",
            "An unknown name in vim.g.loki_extras only prints a warning.",
        },
    },
    terminal = {
        title = "Integrated terminal", tag = "loki-terminal",
        intro = {
            "toggleterm gives a terminal at the bottom. <C-\\> toggles it; a count opens a numbered terminal (2<C-\\>), :TermSelect picks one.",
            "Run Neovim inside tmux or zellij if you want terminals that survive closing the editor.",
        },
        groups = { "Terminal" },
        see = "docs/TERMINAL.md",
        fail = {
            "<C-\\> does nothing: another plugin or your terminal took the key. Rebind it with toggleterm opts (docs/MIGRATING.md, section 4).",
            "jk or Esc do nothing in lazygit/fzf: by design, only the toggleterm terminal uses them.",
        },
    },
    troubleshooting = {
        title = "Troubleshooting", tag = "loki-troubleshooting",
        intro = {
            "Start with :checkhealth loki. It checks versions, required tools, install state, your personal files, key conflicts, safety copies, the language table and enabled extras.",
            "Then :checkhealth (everything), :Lazy (plugins), :Mason (servers and tools), :LokiLsp (this buffer).",
            "docs/TROUBLESHOOTING.md collects every symptom with its cause and fix.",
        },
        commands = { "LokiInfo", "LokiKeys", "LokiLockReset", "LokiBackup" },
        see = "docs/TROUBLESHOOTING.md",
        fail = {
            "Icons show as boxes: set a Nerd Font in your terminal.",
            "Plugins fail to install: needs git and a network; :Lazy then I retries.",
            "My lua/user/ files are gone after a re-clone: scripts/user-layer.sh backups, then import the newest.",
        },
    },
}

M.topic_order = { "keys", "lsp", "git", "files", "languages", "extras", "terminal", "troubleshooting" }

-- ===========================================================================
-- Lookups
-- ===========================================================================
local function as_list(v)
    if type(v) == "table" then
        return v
    end
    return { v }
end
M.as_list = as_list

-- Entry for (mode, lhs), or nil.
function M.key(mode, lhs)
    for _, e in ipairs(M.keys) do
        if vim.tbl_contains(as_list(e.mode), mode) and vim.tbl_contains(as_list(e.lhs), lhs) then
            return e
        end
    end
end

function M.desc(mode, lhs)
    local e = M.key(mode, lhs)
    return e and e.desc or lhs
end

function M.command(name)
    for _, c in ipairs(M.commands) do
        if c.name == name then
            return c
        end
    end
end

-- Command description for nvim_create_user_command.
function M.command_desc(name)
    local c = M.command(name)
    return c and c.desc or name
end

-- Keys the shipped config creates itself (not extras, not documented-only).
function M.shipped_keys()
    return vim.tbl_filter(function(e)
        return e.set ~= false and not e.extra
    end, M.keys)
end

-- Keys of the extras that are enabled right now.
function M.extra_keys(enabled)
    local on = {}
    for _, n in ipairs(enabled) do
        on[n] = true
    end
    return vim.tbl_filter(function(e)
        return e.extra and on[e.extra] and e.set ~= false
    end, M.keys)
end

function M.topic_keys(topic)
    local want = {}
    for _, g in ipairs(M.topics[topic].groups or {}) do
        want[g] = true
    end
    return vim.tbl_filter(function(e)
        return want[e.group]
    end, M.keys)
end

-- Create one entry's key(s). `map` defaults to vim.keymap.set at call time, so
-- util/keyguard's wrapper sees it.
function M.apply(e, map)
    map = map or vim.keymap.set
    if e.when and not e.when() then
        return
    end
    local rhs = e.rhs
    if e.lsp then
        rhs = function()
            require("util.lsp").notice(e)
        end
    end
    local opts = vim.tbl_extend("force", { desc = e.desc }, e.opts or {})
    for _, lhs in ipairs(as_list(e.lhs)) do
        map(e.mode, lhs, rhs, opts)
    end
end

return M
