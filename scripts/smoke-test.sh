#!/usr/bin/env bash
# Quick check that the Loki modules load and the generators run (headless),
# then run scripts/check-help.sh. Exits non-zero on ANY failure.
# Uses your active config (pass NVIM_APPNAME=loki for an alongside install).
#   scripts/smoke-test.sh
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="$(pwd -P)"

# Alongside install: use it unless the caller already chose one.
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

# util/smoke.lua runs inside Neovim and calls :cquit on failure. (A plain
# `+lua assert(...)` prints an error but still exits 0, so it could never fail.)
nvim --headless "+lua require('util.smoke').run()" "+qa" 2>&1

scripts/check-help.sh

echo "Smoke test passed. Now open nvim and try :LokiHelp, :LokiKeys, :LokiTutor, :checkhealth loki"
