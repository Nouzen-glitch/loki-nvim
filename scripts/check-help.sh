#!/usr/bin/env bash
# Fails when the help system has drifted from the code. Checks:
#   - every shipped mapping and every Loki command has a description
#   - every <leader> prefix has a which-key group label
#   - every registry key/command has desc, long text, a group, and a resolvable doc link
#   - every shipped key is written in docs/KEYBINDINGS.md
#   - every command is listed in docs/ENVIRONMENT_GUIDE.md
#   - every extra is in docs/EXTRAS.md, docs/COMPONENTS.md and docs/KEYBINDINGS.md
#   - doc/loki.txt matches the registry, and :help loki resolves
# All extras are enabled for the run so their keys are checked too.
#   scripts/check-help.sh
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="$(pwd -P)"

if [[ -z "${NVIM_APPNAME:-}" ]]; then
    config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    for name in loki nvim; do
        link="$config_home/$name"
        if [[ -e "$link" && "$(readlink -f "$link")" == "$REPO" ]]; then
            [[ "$name" == "nvim" ]] || export NVIM_APPNAME="$name"
            break
        fi
    done
fi

nvim --headless \
    --cmd "lua vim.g.loki_extras = { 'sessions', 'dashboard', 'docker', 'database', 'rest', 'dap', 'lint', 'surround' }" \
    "+lua require('util.check_help').run()" \
    "+qa" 2>&1
