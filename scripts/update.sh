#!/usr/bin/env bash
# Update Loki Neovim from its git remote.
#
#   scripts/update.sh           show what is incoming, then pull
#   scripts/update.sh --check   only show what is incoming; change nothing
#
# Your personal files (lua/user/, languages_local.lua) are gitignored, so an
# update never touches them. If you edited a shipped file, the script stops
# and tells you, instead of pulling over your edits.
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
CHECK_ONLY=0

say() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

while (($#)); do
    case "$1" in
        --check|--dry-run) CHECK_ONLY=1 ;;
        -h|--help)         sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)                 die "Unknown option: $1 (try --help)" ;;
    esac
    shift
done

cd "$SOURCE_DIR"
command -v git >/dev/null 2>&1 || die "git is required."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "$SOURCE_DIR is not a git checkout, so it cannot be updated this way."
git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 \
    || die "This branch has no upstream. Set one, e.g.: git branch --set-upstream-to=origin/main"

say "== Loki Neovim update =="
say "Checking for changes..."
git fetch --quiet || die "Could not reach the remote. Check your network connection."

incoming="$(git rev-list --count 'HEAD..@{u}')"
local_only="$(git rev-list --count '@{u}..HEAD')"

if ((incoming == 0)); then
    say "Already up to date."
    ((local_only > 0)) && say "(You have $local_only local commit(s) that are not pushed.)"
    say "Plugins update separately: run :Lazy in Neovim and press U."
    exit 0
fi

say
say "$incoming new change(s):"
git log --oneline --no-decorate 'HEAD..@{u}' | sed 's/^/  /'

notes="$(git diff HEAD '@{u}' -- CHANGELOG.md 2>/dev/null | grep '^+' | grep -v '^+++' | sed 's/^+//' || true)"
if [[ -n "$notes" ]]; then
    say
    say "What's new (from CHANGELOG.md):"
    printf '%s\n' "$notes" | sed 's/^/  /'
fi

lock_changed=0
git diff --name-only HEAD '@{u}' | grep -qx 'lazy-lock.json' && lock_changed=1

dirty="$(git status --porcelain --untracked-files=no)"
if ((CHECK_ONLY)); then
    say
    say "Check only: nothing was changed. Run scripts/update.sh to apply."
    [[ -z "$dirty" ]] || say "Note: you have local edits to shipped files (see below); the update will stop until they are committed or stashed."
fi
if [[ -n "$dirty" ]]; then
    say
    say "You have local changes to shipped files:"
    printf '%s\n' "$dirty" | sed 's/^/  /'
    if ((CHECK_ONLY == 0)); then
        say
        say "Not updating, so your edits are not overwritten. Either:"
        say "  git stash        # set them aside, run this script, then: git stash pop"
        say "  git commit -am 'my changes'"
        say "Personal settings belong in lua/user/ (see docs/MIGRATING.md); files there never block an update."
        exit 1
    fi
fi
((CHECK_ONLY)) && exit 0

if ((local_only > 0)); then
    die "You have $local_only local commit(s) that are not on the remote, so a fast-forward is impossible. Run: git pull --rebase"
fi

# Your personal files are not in git; keep a safety copy anyway.
if [[ -x "$SOURCE_DIR/scripts/user-layer.sh" ]]; then
    "$SOURCE_DIR/scripts/user-layer.sh" backup || true
fi

git pull --ff-only --quiet || die "Could not fast-forward. Run: git pull --rebase"

say
say "Updated."
say "Next:"
say "  1. Restart Neovim. New plugins install automatically."
say "  2. Run :Lazy clean to remove plugins that were dropped."
if ((lock_changed)); then
    say "  3. The shipped plugin versions changed. To adopt them: :LokiLockReset, restart,"
    say "     then :Lazy restore. (Skip this to keep the versions you have.)"
fi
say "  Verify with :checkhealth loki"
say "  Tip: :LokiHelp shows what you can do; :LokiKeys lists shipped keys your keymaps replace."
