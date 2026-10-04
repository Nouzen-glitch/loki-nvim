#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
REPO="$(pwd -P)"

# If this config was installed alongside (NVIM_APPNAME), generate for that
# install unless the caller already chose one.
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

nvim --headless "+lua require('util.cheatsheet').generate()" "+qa"
