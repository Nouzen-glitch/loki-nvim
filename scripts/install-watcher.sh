#!/usr/bin/env bash
# Install (or remove) the optional systemd user units that regenerate the
# cheatsheet when files in the repo folder change. The files in systemd/ are
# templates: @REPO@ is replaced with the real path of this repo.
#
#   scripts/install-watcher.sh            install and enable
#   scripts/install-watcher.sh --remove   disable and delete the units
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

say() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

command -v systemctl >/dev/null 2>&1 || die "systemctl not found (systemd user units are Linux only)."

case "${1:-}" in
    --remove)
        systemctl --user disable --now cheatsheet-watch.path 2>/dev/null || true
        rm -f "$UNIT_DIR/cheatsheet-watch.path" "$UNIT_DIR/cheatsheet-watch.service"
        systemctl --user daemon-reload
        say "Removed the cheatsheet watcher."
        exit 0 ;;
    ""|--install) ;;
    -h|--help) sed -n '2,7p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "Unknown option: $1" ;;
esac

mkdir -p "$UNIT_DIR"
for unit in cheatsheet-watch.path cheatsheet-watch.service; do
    sed "s|@REPO@|$SOURCE_DIR|g" "$SOURCE_DIR/systemd/$unit" >"$UNIT_DIR/$unit"
done
chmod +x "$SOURCE_DIR/scripts/generate-cheatsheet.sh"
systemctl --user daemon-reload
systemctl --user enable --now cheatsheet-watch.path
say "Installed. Watching $SOURCE_DIR (top-level files only; saves inside Neovim are handled by Neovim itself)."
