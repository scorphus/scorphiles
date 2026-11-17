#!/bin/bash
# setup.sh: turns a Mac with Homebrew and this repo into the working setup.
# Safe to re-run: each step only does what is missing.
#   --dry-run   print what would be done, change nothing
#   --check     report what is missing or broken, change nothing; exits 1 if anything is
set -uo pipefail
cd "$(dirname "$0")"

MODE=${1:-}
run() { echo "+ $*"; [ "$MODE" = --dry-run ] || "$@"; }
FAILED=0
check() { if [ -z "$2" ]; then echo $'\e[32m✓\e[0m' "$1"; else echo $'\e[31m✗\e[0m' "$1"; echo "$2"; FAILED=1; fi; }

# stow packages; each folder mirrors its files' place under ~
PACKAGES="bin claude fish ghostty git hammerspoon peco tmux vim zed"
# created as real folders first, so stow links what is inside them, never the folder itself
REAL_DIRS="$HOME/.config $HOME/.config/fish $HOME/.config/fish/conf.d $HOME/.config/zed $HOME/.claude"
STOW="stow --ignore=TODO\.md -t $HOME"

echo "== packages"
if [ "$MODE" = --check ]; then
    check Brewfile "$(out=$(brew bundle check --file=Brewfile --verbose --no-upgrade 2>&1) || echo "$out")"
else
    brew bundle check --file=Brewfile >/dev/null || run brew bundle --file=Brewfile || exit 1
fi

echo "== links"
for d in $REAL_DIRS; do
    if [ "$MODE" = --check ]; then
        check "$d is a real folder" "$([ -d "$d" ] && [ ! -L "$d" ] || echo "  missing or a link")"
    else
        [ -d "$d" ] || run mkdir -p "$d" || exit 1
    fi
done
for p in $PACKAGES; do
    if [ "$MODE" = --check ]; then
        check "$p" "$($STOW -n -v "$p" 2>&1 | grep -v '^WARNING: in simulation mode')"
    else
        run $STOW --restow "$p" || exit 1
    fi
done

if [ "$MODE" = --check ]; then
    echo "== shells"
    check "fish starts clean" "$(fish -i -c exit 2>&1)"
    check "git config parses" "$(git config --list 2>&1 >/dev/null)"
fi

exit $FAILED
