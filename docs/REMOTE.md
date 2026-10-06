# Remote development

There is no "remote workspace" feature. The dependable approach is to run
Neovim **where the code is** and use your local terminal as the screen.

## Over SSH (recommended: inside tmux)

1. Install Neovim 0.11+ and the tools from [README.md](README.md) on the remote
   host, then clone the repo and run `scripts/install.sh` there.
2. `ssh host`, start `tmux`, run `nvim`. If the connection drops, `ssh host`
   again and `tmux attach`: the editor, its terminals and running commands are
   still there.
3. Use a Nerd Font in your **local** terminal (icons are drawn locally).

Your personal files (`lua/user/`) are not in git: move them with
`scripts/user-layer.sh export` and `import` ([INSTALL.md](INSTALL.md), scenario G).

## Clipboard over SSH

This config yanks to the system clipboard (`clipboard=unnamedplus`), which does
not exist on a headless host. Use OSC 52, which asks your local terminal to
set its clipboard. Put this in `lua/user/options.lua` on the remote:

```lua
vim.g.clipboard = {
    name = "OSC 52",
    copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    -- Most terminals do not answer paste requests: paste from the unnamed register.
    paste = {
        ["+"] = function() return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") } end,
        ["*"] = function() return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") } end,
    },
}
```

The local terminal must allow OSC 52, and inside `tmux` set
`set -g set-clipboard on`. Check with `:checkhealth vim.provider`.

## In a container

```bash
docker exec -it <container> nvim          # Neovim installed in the container
devcontainer exec --workspace-folder . nvim   # with the devcontainer CLI
```

Install Neovim, git, ripgrep, a C compiler, Node.js and Python in the image (or
the devcontainer features), clone the config inside, and mount a volume for
`~/.local/share/nvim` so plugins and Mason tools survive a rebuild.

## WSL 2

Use Neovim inside the WSL distribution, keep the project in the Linux
filesystem (not `/mnt/c`, which is slow for file watching and git), and use a
Nerd Font in Windows Terminal. For the clipboard, install `wl-clipboard` or
`xclip`, or use the OSC 52 snippet above.

## Limits

Images in the terminal ([EXTRAS.md](EXTRAS.md#preview)) need a kitty-graphics
terminal and do not work through plain SSH + tmux unless passthrough is set up.
Debugging and tests run on the remote host, which is usually what you want.

## Where next

[INSTALL.md](INSTALL.md), [TERMINAL.md](TERMINAL.md), [AI.md](AI.md).
