*loki.txt*  Loki Neovim: keys, commands and features

==============================================================================
CONTENTS                                                          *loki-contents*

    1. Overview .......................................... |loki|
    2. Keys and the key popup ............................ |loki-keys|
    3. Code intelligence (LSP), diagnostics and completion .. |loki-lsp|
    4. Git ............................................... |loki-git|
    5. Finding and opening files ......................... |loki-files|
    6. Adding and changing languages ..................... |loki-languages|
    7. Extras (opt-in features) .......................... |loki-extras|
    8. Integrated terminal ............................... |loki-terminal|
    9. Troubleshooting ................................... |loki-troubleshooting|
    10. Commands ......................................... |loki-commands|

This file is generated from lua/util/registry.lua (scripts/gen-help.sh). The same text
is shown by :LokiHelp. Longer guides live in the docs/ folder; :LokiDocs browses them.

==============================================================================
1. Overview                                                             *loki*

    Loki Neovim is a Neovim configuration with LSP, completion, fuzzy
    finding, git, formatting and an integrated terminal. <leader> is the
    Space bar.
    Find your way: <leader>? lists every key, <leader>fk searches keys,
    <leader>fc searches commands, :LokiHelp opens the one-screen guide.
    Check your setup with :checkhealth loki.

==============================================================================
2. Keys and the key popup                                          *loki-keys*

    Leader is the Space bar. Press a key that starts a sequence (<leader>, g, z,
    [, ], <C-w>, or an operator such as d, y, c) and wait a moment:
    a popup lists what can follow, each with a description. Type the next key to
    go deeper; <BS> goes up one level, <Esc> closes it.
    After d, y or c the popup lists motions and text objects (type i or a to see
    inner/around objects such as quotes, brackets, arguments).
    <leader>? shows every key, <leader>fk searches them by description.

    Fundamentals
    `jk` [i] Exit Insert mode
        Press j then k quickly in Insert mode to go back to Normal mode
        without reaching for Escape. Typed slowly, you just get the letters j
        and k.
        Example: Type some text, then press jk.

    `<Up> <Down> <Left> <Right>` [n,i,v] Arrow key disabled (learn hjkl)
        The arrow keys do nothing on purpose, so that real Vim movement (h j k
        l, w b e) becomes a habit. Turn the ban off with
        vim.g.loki_disable_arrows = false in lua/user/options.lua.

    `n` [n] Next search result (centered)
        Jumps to the next match of the last search and keeps it in the middle
        of the window. Start a search with / (forward) or ? (backward).

    `N` [n] Previous search result (centered)
        Jumps to the previous match of the last search and keeps it in the
        middle of the window.

    `j` [n] Down (display line; with a count, real lines)
        Moves down one screen line, so long wrapped lines are walked through
        naturally. With a count (5j) it moves that many real lines, which
        keeps relative line numbers useful.

    `k` [n] Up (display line; with a count, real lines)
        Moves up one screen line. With a count (5k) it moves that many real
        lines.

    `<` [v] Indent left, keep selection
        Shifts the selected lines left by one shiftwidth and keeps them
        selected, so you can press < again.

    `>` [v] Indent right, keep selection
        Shifts the selected lines right by one shiftwidth and keeps them
        selected, so you can press > again.

    `<Esc>` [n] Clear search highlight
        Removes the yellow highlight left by a search. The search itself is
        kept, so n and N still work.

    `<C-s>` [n] Save file
        Writes the current buffer to disk. Format on save runs first when it
        is enabled (see :LokiFormat). In Insert mode <C-s> is Neovim's
        signature help instead.

    `<leader>q` [n] Quit window
        Closes the current window; the last window quits Neovim. With unsaved
        changes Neovim asks what to do instead of failing.

    `<C-d>` [n] Half page down, centered
        Scrolls half a screen down and centers the cursor line, so you do not
        lose your place.

    `<C-u>` [n] Half page up, centered
        Scrolls half a screen up and centers the cursor line.

    `J` [v] Move selected lines down
        Moves the selected lines one line down and re-indents them. The
        selection stays active.

    `K` [v] Move selected lines up
        Moves the selected lines one line up and re-indents them. The
        selection stays active.

    `p` [x] Paste over selection, keep register
        Pastes over the selected text without replacing what you yanked, so
        you can paste the same text again. The replaced text is discarded (it
        goes to the black-hole register).


    Windows
    `<C-h>` [n] Focus left window
        Moves the cursor to the window on the left. <C-j>, <C-k> and <C-l> do
        the same for down, up and right. In a terminal that sends Backspace as
        <C-h>, Backspace will also move windows in Normal mode.

    `<C-j>` [n] Focus lower window
        Moves the cursor to the window below.

    `<C-k>` [n] Focus upper window
        Moves the cursor to the window above.

    `<C-l>` [n] Focus right window
        Moves the cursor to the window on the right.

    `<leader>ww` [n] Cycle to the next window
        Jumps to the next window in order, wrapping around at the end.

    `<leader>wd` [n] Close this window
        Closes the current window. The buffer stays loaded (use <leader>bd to
        remove it).

    `<leader>wv` [n] Split window vertically
        Splits the window into two side by side, showing the same buffer in
        both.

    `<leader>ws` [n] Split window horizontally
        Splits the window into two, one above the other, showing the same
        buffer in both.


    Buffers
    `H` [n] Previous buffer
        Switches to the previous open file. The open buffers are shown along
        the top of the screen.

    `L` [n] Next buffer
        Switches to the next open file. The open buffers are shown along the
        top of the screen.

    `<leader>bd` [n] Close this buffer (file)
        Removes the current buffer from the list of open files. Windows
        showing it switch to another buffer.


    Editing
    `gc` [n,x] Comment: toggle with a motion or selection
        Neovim's built-in commenting. gc followed by a motion comments that
        range (gcap: a paragraph); in Visual mode gc comments the selection.

    `gcc` [n] Comment: toggle the current line
        Comments or uncomments the current line; 3gcc does three lines.

    `a` [o,x] Around a text object (mini.ai)
        After an operator (d, c, y, v) a<key> selects the object plus its
        surroundings and i<key> only what is inside: ib is inside brackets, aq
        around any quotes, if inside a function call, ia an argument.
        Example: daq deletes a quoted string with its quotes; cia changes one argument.


    If it does not work
  - No popup appears: run :checkhealth which-key. Your terminal may also
    swallow the key.
  - A key does nothing or does something else: <leader>fk shows what it is
    mapped to; :LokiKeys lists shipped keys your own keymaps replaced.

    More: docs/KEYBINDINGS.md   (:LokiDocs browses the docs)

==============================================================================
3. Code intelligence (LSP), diagnostics and completion              *loki-lsp*

    A language server gives go-to-definition, references, rename, hover docs,
    completion and diagnostics.
    The LSP keys exist only in buffers where a server is attached. Elsewhere they
    print a notice, and :LokiLsp explains why nothing is attached.
    Servers come from the language table (see :LokiHelp languages); Mason installs
    them.

    LSP
    `K` [n] Hover: show docs for the symbol under the cursor
        Opens a floating window with the documentation and type of the symbol
        under the cursor. Press K again to enter the window and scroll it;
        <Esc> or moving away closes it.
        Example: Put the cursor on a function name and press K.

    `gd` [n] Go to definition (<C-o> jumps back)
        Jumps to where the symbol under the cursor is defined, even in another
        file. <C-o> goes back to where you were and <C-i> forward again.

    `gD` [n] Go to declaration
        Jumps to the declaration of the symbol (in C and C++ this is usually
        the header). Many servers treat it the same as gd.

    `gi` [n] Go to implementation
        Jumps to the implementation of an interface or abstract method. When
        there are several, a list opens.

    `gr` [n] References: list every use of the symbol
        Lists every place the symbol is used in the quickfix window. Move with
        j/k and press Enter to jump. A lone gr waits 400 ms because Neovim
        also has grr, gra and grn.

    `<leader>rn` [n] Rename symbol everywhere (asks for the new name)
        Prompts for a new name and renames the symbol in every file of the
        project. Use :wa afterwards to save all the files that changed.

    `<leader>ca` [n,v] Code action: pick a quick fix or refactor
        Opens a menu of fixes and refactors the server offers at the cursor,
        such as adding an import. Select with Enter.

    `<leader>D` [n] Go to type definition
        Jumps to the definition of the type of the symbol under the cursor,
        not of the symbol itself.

    `<leader>ds` [n] Symbols in this file (location list)
        Fills the location list with the functions, classes and variables of
        this file. For a searchable picker use <leader>fs instead.

    `<leader>ih` [n] Toggle inlay hints (inline types and parameter names)
        Shows or hides the small hints that servers draw inside the code, such
        as parameter names. Not every server provides them.


    Diagnostics
    `[d` [n] Previous diagnostic (opens its message)
        Jumps to the previous error or warning in this buffer and shows its
        message in a float.

    `]d` [n] Next diagnostic (opens its message)
        Jumps to the next error or warning in this buffer and shows its
        message in a float.

    `<leader>de` [n] Show the diagnostic message at the cursor
        Opens a float with the full text of the error or warning on the cursor
        line.

    `<leader>dq` [n] Send all diagnostics to the quickfix list
        Collects every diagnostic of every open buffer into the quickfix list
        and opens it. Walk it with :cnext and :cprev.

    `<leader>xx` [n] Diagnostics panel: all files (toggle)
        Opens or closes the Trouble panel listing the problems of all open
        files. Inside it press ? for its keys, Enter to jump and q to close.

    `<leader>xX` [n] Diagnostics panel: this buffer only (toggle)
        Like <leader>xx but only lists the problems of the current file.


    Completion
    `<C-Space>` [i] Open the completion menu
        Forces the completion menu open even before you type. Completion also
        opens by itself while you type.

    `<C-j>` [i] Next completion item
        Selects the next item of the open completion menu. Nothing is
        preselected until you move.

    `<C-k>` [i] Previous completion item
        Selects the previous item of the open completion menu.

    `<Tab>` [i,s] Next item, or jump to the next snippet field
        With the menu open it selects the next item. Inside an expanded
        snippet it jumps to the next field; otherwise it inserts a Tab.

    `<S-Tab>` [i,s] Previous item, or jump back in a snippet
        With the menu open it selects the previous item. Inside a snippet it
        jumps to the previous field.

    `<CR>` [i] Accept the selected completion item
        Inserts the selected item. If nothing is selected, Enter just starts a
        new line.

    `<C-e>` [i] Close the completion menu
        Closes the menu and keeps what you typed.

    `<C-d>` [i] Scroll completion docs up
        Scrolls the documentation window next to the menu up. <C-f> scrolls it
        down.


    Commands
    :LokiLsp
        Language support for this buffer: server, root, formatter, parser, and
        what to do if one is missing. One screen that explains why completion,
        go-to-definition or formatting does or does not work in the current
        file.
    :LokiFormat [on|off|status]
        Turn format on save on or off for this session. Switches automatic
        formatting when you save. It only lasts until you quit; <leader>cf
        always formats on demand.
        Example: :LokiFormat off

    If it does not work
  - Run :LokiLsp first: it names the server, its root and what is missing.
  - :Mason shows installed servers (a check mark); :MasonLog shows install
    errors; :checkhealth vim.lsp lists attached clients.
  - Mason needs Node.js, Python 3 and sometimes Go: :checkhealth loki lists
    missing toolchains.

    More: docs/LSP.md   (:LokiDocs browses the docs)

==============================================================================
4. Git                                                              *loki-git*

    Gitsigns marks changed lines in the sign column. A hunk is one contiguous
    block of changes.
    Stage, reset, preview and blame hunks without leaving the file. In Visual
    mode, stage or reset only the selected lines.

    Git
    `]h` [n] Next git hunk
        Jumps to the next changed block (hunk) in this file, as marked in the
        sign column.

    `[h` [n] Previous git hunk
        Jumps to the previous changed block (hunk) in this file.

    `<leader>hs` [n,v] Stage hunk (in Visual mode: only the selected lines)
        Stages the hunk under the cursor for the next commit. In Visual mode
        only the selected lines are staged.

    `<leader>hr` [n,v] Reset hunk: discard changes (in Visual mode: only the
    selected lines)
        Throws away the uncommitted change in the hunk, restoring the
        committed text. In Visual mode only the selected lines are reset. u
        undoes it.

    `<leader>hu` [n] Undo the last stage of a hunk
        Unstages the hunk you staged last with <leader>hs.

    `<leader>hp` [n] Preview hunk (floating diff)
        Shows the old and new text of the hunk under the cursor in a float.

    `<leader>hb` [n] Blame: who changed this line (full commit message)
        Shows the author, date and message of the commit that last changed the
        cursor line.

    `<leader>hB` [n] Toggle blame text at the end of the cursor line
        Shows or hides a faded 'author, date, summary' at the end of the
        current line, following the cursor.

    `<leader>hd` [n] Diff this file against the index (side by side)
        Opens a side-by-side diff of the file against what is staged. Close
        the extra window with :q.


    If it does not work
  - No signs: the file must be inside a git repository and be tracked or new.
  - Blame is empty on a new file: it has no commit yet.

    More: docs/GIT.md   (:LokiDocs browses the docs)

==============================================================================
5. Finding and opening files                                      *loki-files*

    Telescope is the fuzzy finder behind the <leader>f keys. Inside a picker:
    <C-j>/<C-k> move, Enter opens, <C-x>/<C-v> open in a split, <C-q> sends
    results to the quickfix list, ? or <C-/> lists its keys.
    The file tree (<leader>e) has its own keys; press g? inside it.

    Find
    `<leader>ff` [n] Find files by name (fuzzy)
        Opens a picker over every file in the project. Type part of the name,
        move with <C-j>/<C-k>, Enter opens it.
        Example: <leader>ff, type 'lsp', Enter.

    `<leader>fg` [n] Search text in the project (needs ripgrep)
        Searches the contents of all files as you type. It needs ripgrep (rg);
        :checkhealth loki tells you if it is missing.

    `<leader>fb` [n] Pick an open buffer
        Lists the open files. Handy when there are more of them than fit in
        the tabline.

    `<leader>fh` [n] Search Neovim help (try: loki)
        Fuzzy-searches every help tag, including this config's own :help loki
        pages.
        Example: <leader>fh, type 'loki'.

    `<leader>fr` [n] Recent files
        Lists the files you opened recently, newest first.

    `<leader>fc` [n] Find and run a command
        Searches all : commands, including the Loki ones. Enter runs the
        selected command.

    `<leader>fk` [n] Search all keymaps
        Searches every key mapping with its description. Use it to find out
        what a key does or which key does something.

    `<leader>fC` [n] Open the generated cheatsheet
        Regenerates and opens the cheatsheet built from the running editor,
        including your own keys.

    `<leader>fi` [n] Loki guide: what you can do
        Opens the one-screen guide. Add a topic for details, for example
        :LokiHelp lsp.

    `<leader>fs` [n] Symbols in this file (searchable)
        Lists the functions, classes and variables of the current file and
        jumps to the one you pick. Needs a language server.

    `<leader>fS` [n] Symbols in the whole project (type to search)
        Searches symbol names across the whole project; the list updates as
        you type. Needs a language server.

    `<leader>fd` [n] Diagnostics of open files (searchable)
        Lists errors and warnings of all open buffers in a picker. For a
        persistent panel use <leader>xx.

    `<leader>fG` [n] Changed files in git (with a diff preview)
        Lists the files git sees as changed, with a preview of each diff.
        Needs the folder to be a git repository.

    `<leader>?` [n] Show all keybindings
        Opens the which-key popup with every global key, grouped by prefix.


    Explorer
    `<leader>e` [n] Toggle file explorer
        Opens or closes the file tree on the left. Inside it press g? for its
        own key list.

    `<leader>E` [n] Reveal current file in the explorer
        Opens the file tree and moves its cursor to the file you are editing.

    `<leader>cf` [n,v] Format file/selection
        Formats the whole file or the selection with the formatter of the
        language, or the language server when there is none. Saving also
        formats, unless :LokiFormat off.


    Commands
    :LokiDocs
        Browse the docs/ folder with Telescope. Opens a Telescope picker over
        the markdown docs shipped with the config; Enter opens one in a
        buffer.

    If it does not work
  - <leader>fg does nothing: install ripgrep (rg).
  - Icons show as boxes: use a Nerd Font in your terminal.

    More: docs/FINDING.md   (:LokiDocs browses the docs)

==============================================================================
6. Adding and changing languages                              *loki-languages*

    Nothing is installed unless a language is listed. One line in
    lua/config/languages_local.lua (:LokiEdit languages) gives a language its
    server, tree-sitter parser, formatter, linter and tools.
    Example: go = { lsp = "gopls", parser = "go", formatter = "gofumpt", tools = {
    "gofumpt" } },
    Restart Neovim afterwards and watch :Mason. Disable a default with rust =
    false,
    Three naming systems: lsp uses lspconfig names (ts_ls), formatter and linter
    use Conform / nvim-lint names, tools uses Mason package names.

    Commands
    :LokiEdit {options|keymaps|plugins|languages}
        Create/open your personal file: options, keymaps, plugins, languages.
        Creates the file in lua/user/ (or languages_local.lua) from its
        example and opens it. Your files are not in git, so run :LokiBackup
        now and then.
        Example: :LokiEdit keymaps
    :LokiLsp
        Language support for this buffer: server, root, formatter, parser, and
        what to do if one is missing. One screen that explains why completion,
        go-to-definition or formatting does or does not work in the current
        file.

    If it does not work
  - :checkhealth loki validates the language table and names typos.
  - Server missing in :Mason: wrong lspconfig name, or Node/Python/Go is
    missing.

    More: docs/ADDING_LANGUAGES.md   (:LokiDocs browses the docs)

==============================================================================
7. Extras (opt-in features)                                      *loki-extras*

    Heavier features are off until you enable them in lua/user/options.lua, then
    restart:
    vim.g.loki_extras = { "sessions", "dashboard", "dap" }
    :LokiExtras lists them: sessions, dashboard, docker, database, rest, dap,
    lint, surround.
    Keys below exist only while their extra is enabled.

    Sessions
    `<leader>ss` [n] Restore session for this folder
        Reopens the files and splits you had in this folder (and git branch)
        the last time you quit. Never happens by itself.

    `<leader>sl` [n] Restore last session
        Restores the most recent session of any folder.

    `<leader>sd` [n] Do not save this session
        Stops recording, so quitting does not overwrite the saved session of
        this folder.


    Clients
    `<leader>kk` [n] Docker (lazydocker in a floating terminal)
        Opens lazydocker in a floating terminal. It needs docker and
        lazydocker installed; otherwise you get a message.

    `<leader>kd` [n] Database UI (toggle)
        Opens or closes the vim-dadbod database sidebar. Press A inside it to
        add a connection; keep passwords in environment variables.

    `<leader>kr` [n] Run the HTTP request under the cursor
        In a .http file, sends the block under the cursor (between ### lines)
        with curl and shows the response in a split.


    Debug
    `<leader>tb` [n] Toggle breakpoint
        Sets or removes a breakpoint on the cursor line.

    `<leader>tc` [n] Debug: start / continue
        Starts a debug session (choosing a configuration if needed) or
        continues to the next breakpoint.

    `<leader>tu` [n] Toggle debug UI
        Shows or hides the variables, stack and console panels.

    `<leader>tx` [n] Debug: stop
        Ends the debug session and closes the debug UI.

    `<F5>` [n] Debug: start / continue
        Same as <leader>tc. Some terminals intercept F-keys; the <leader>t
        keys always work.

    `<F9>` [n] Toggle breakpoint
        Same as <leader>tb: sets or removes a breakpoint on the cursor line.

    `<F10>` [n] Debug: step over
        Runs the current line without entering function calls.

    `<F11>` [n] Debug: step into
        Steps into the function call on the current line.

    `<S-F11>` [n] Debug: step out
        Runs until the current function returns.


    Code
    `<leader>cl` [n] Lint this buffer now
        Runs the linters configured for this filetype and shows the result as
        diagnostics. Linting also runs on save.


    Surround
    `gsa` [n] Surround: add around a motion
        gsa followed by a motion and a character wraps the text: gsaiw) puts
        parentheses around the word. In Visual mode gsa wraps the selection.
        Example: gsaiw" wraps the word in double quotes.

    `gsd` [n] Surround: delete the surrounding character
        gsd followed by the character removes it: gsd" removes the quotes
        around the cursor.

    `gsr` [n] Surround: replace the surrounding character
        gsr followed by the old and the new character: gsr"' changes double
        quotes to single quotes.


    Commands
    :LokiExtras
        List opt-in extras and which are enabled. Shows every extra with an
        [x] when it is enabled. Enable one in lua/user/options.lua with
        vim.g.loki_extras.
    :LokiRest
        Run the HTTP request under the cursor (.http file). Same as
        <leader>kr. Sends the request block under the cursor with curl.

    If it does not work
  - :checkhealth loki lists the external tools an enabled extra is missing
    (always a warning).
  - An unknown name in vim.g.loki_extras only prints a warning.

    More: docs/EXTRAS.md   (:LokiDocs browses the docs)

==============================================================================
8. Integrated terminal                                         *loki-terminal*

    toggleterm gives a terminal at the bottom. <C-\> toggles it; a count opens a
    numbered terminal (2<C-\>), :TermSelect picks one.
    Run Neovim inside tmux or zellij if you want terminals that survive closing
    the editor.

    Terminal
    `<C-\>` [n,i,t] Toggle the bottom terminal
        Opens or hides the terminal at the bottom, from any mode. A count
        picks a numbered terminal: 2<C-\> opens terminal 2. :TermSelect picks
        one from a list.

    `jk` [t] Terminal: back to Normal mode
        In the toggleterm terminal only: leaves Terminal mode so you can
        scroll and search the output. Press i to type again.

    `<Esc>` [t] Terminal: back to Normal mode
        Same as jk, for the toggleterm terminal only. Other terminals
        (lazygit, fzf, vim) keep Esc for their program.

    `<C-h>` [t] Terminal: focus left window
        Leaves the terminal and moves to the window on the left. <C-j>, <C-k>,
        <C-l> do the same for the other directions.

    `<C-j>` [t] Terminal: focus lower window
        Leaves the terminal and moves to the window below.

    `<C-k>` [t] Terminal: focus upper window
        Leaves the terminal and moves to the window above.

    `<C-l>` [t] Terminal: focus right window
        Leaves the terminal and moves to the window on the right.


    If it does not work
  - <C-\> does nothing: another plugin or your terminal took the key. Rebind
    it with toggleterm opts (docs/MIGRATING.md, section 4).
  - jk or Esc do nothing in lazygit/fzf: by design, only the toggleterm
    terminal uses them.

    More: docs/TERMINAL.md   (:LokiDocs browses the docs)

==============================================================================
9. Troubleshooting                                      *loki-troubleshooting*

    Start with :checkhealth loki. It checks versions, required tools, install
    state, your personal files, key conflicts, safety copies, the language table
    and enabled extras.
    Then :checkhealth (everything), :Lazy (plugins), :Mason (servers and tools),
    :LokiLsp (this buffer).
    docs/TROUBLESHOOTING.md collects every symptom with its cause and fix.

    Commands
    :LokiInfo
        Show how Loki Neovim was installed. Shows the install mode, where your
        old config was backed up, and how to update or undo.
    :LokiKeys
        Show shipped keys your keymaps replace. Lists shipped keys that your
        lua/user/keymaps.lua replaced, removed or delays through a prefix
        clash.
    :LokiLockReset
        Adopt the plugin versions shipped with the config. Replaces your
        personal plugin lockfile with the shipped one. Restart Neovim and run
        :Lazy restore to apply it.
    :LokiBackup [file]
        Export your personal files to an archive (default:
        ~/loki-user-layer-<date>.tar.gz). Packs lua/user/ and
        languages_local.lua into a .tar.gz, because those files are not in
        git. Restore on any machine with scripts/user-layer.sh import FILE.

    If it does not work
  - Icons show as boxes: set a Nerd Font in your terminal.
  - Plugins fail to install: needs git and a network; :Lazy then I retries.
  - My lua/user/ files are gone after a re-clone: scripts/user-layer.sh
    backups, then import the newest.

    More: docs/TROUBLESHOOTING.md   (:LokiDocs browses the docs)

==============================================================================
10. Commands                                                   *loki-commands*

:LokiHelp [topic]                                                  *:LokiHelp*
        One-screen guide, or a topic: keys, lsp, git, files, languages,
        extras, terminal, troubleshooting. Without an argument it shows the
        overview. With a topic it shows the keys, commands and fixes for that
        area. Tab completes the topic names. The same text is available
        offline as :help loki.
        Example: :LokiHelp lsp

:LokiTutor                                                        *:LokiTutor*
        Short practice tutorial for this config. Opens a scratch buffer with a
        ten-minute tutorial. Nothing you type in it is saved.

:LokiEdit {options|keymaps|plugins|languages}                      *:LokiEdit*
        Create/open your personal file: options, keymaps, plugins, languages.
        Creates the file in lua/user/ (or languages_local.lua) from its
        example and opens it. Your files are not in git, so run :LokiBackup
        now and then.
        Example: :LokiEdit keymaps

:LokiExtras                                                      *:LokiExtras*
        List opt-in extras and which are enabled. Shows every extra with an
        [x] when it is enabled. Enable one in lua/user/options.lua with
        vim.g.loki_extras.

:LokiFormat [on|off|status]                                      *:LokiFormat*
        Turn format on save on or off for this session. Switches automatic
        formatting when you save. It only lasts until you quit; <leader>cf
        always formats on demand.
        Example: :LokiFormat off

:LokiBackup [file]                                               *:LokiBackup*
        Export your personal files to an archive (default:
        ~/loki-user-layer-<date>.tar.gz). Packs lua/user/ and
        languages_local.lua into a .tar.gz, because those files are not in
        git. Restore on any machine with scripts/user-layer.sh import FILE.

:LokiInfo                                                          *:LokiInfo*
        Show how Loki Neovim was installed. Shows the install mode, where your
        old config was backed up, and how to update or undo.

:LokiLockReset                                                *:LokiLockReset*
        Adopt the plugin versions shipped with the config. Replaces your
        personal plugin lockfile with the shipped one. Restart Neovim and run
        :Lazy restore to apply it.

:LokiKeys                                                          *:LokiKeys*
        Show shipped keys your keymaps replace. Lists shipped keys that your
        lua/user/keymaps.lua replaced, removed or delays through a prefix
        clash.

:LokiDocs                                                          *:LokiDocs*
        Browse the docs/ folder with Telescope. Opens a Telescope picker over
        the markdown docs shipped with the config; Enter opens one in a
        buffer.

:LokiLsp                                                            *:LokiLsp*
        Language support for this buffer: server, root, formatter, parser, and
        what to do if one is missing. One screen that explains why completion,
        go-to-definition or formatting does or does not work in the current
        file.

:LokiRest                                                          *:LokiRest*
        Run the HTTP request under the cursor (.http file). Same as
        <leader>kr. Sends the request block under the cursor with curl.

:Cheatsheet                                                      *:Cheatsheet*
        Open live Neovim cheatsheet. Regenerates the cheatsheet from the
        running editor and opens it.

:CheatsheetUpdate                                          *:CheatsheetUpdate*
        Regenerate live Neovim cheatsheet. Regenerates the cheatsheet file
        without opening it.

 vim:tw=78:ts=8:ft=help:norl:
