#!/usr/bin/env bash
# Regenerate doc/loki.txt (:help loki) from lua/util/registry.lua.
# Run it after changing keys, commands or help topics; scripts/check-help.sh
# fails when the committed file is out of date.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="$(pwd -P)"

# Use the alongside install when this repo is linked as one (like smoke-test.sh).
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
    "+lua local ok, err = pcall(function() print('wrote ' .. require('util.helpdoc').write()) end) if not ok then io.stderr:write(tostring(err) .. '\n') vim.cmd('cquit 1') end" \
    "+qa" 2>&1
