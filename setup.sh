#!/bin/bash
# setup.sh: turns a Mac with Homebrew and this repo into the working setup.
# Safe to re-run: each step only does what is missing.
#   --dry-run   print what would be done, change nothing
set -euo pipefail
cd "$(dirname "$0")"

DRY=
[ "${1:-}" = --dry-run ] && DRY=1
run() { echo "+ $*"; [ -n "$DRY" ] || "$@"; }

# stow packages; each folder mirrors its files' place under ~
PACKAGES="bin claude fish ghostty git hammerspoon peco tmux vim zed"
# created as real folders first, so stow links what is inside them, never the folder itself
REAL_DIRS="$HOME/.config $HOME/.config/fish $HOME/.config/fish/conf.d $HOME/.config/zed $HOME/.claude"

echo "== packages"
brew bundle check --file=Brewfile >/dev/null || run brew bundle --file=Brewfile

echo "== links"
for d in $REAL_DIRS; do [ -d "$d" ] || run mkdir -p "$d"; done
for p in $PACKAGES; do
    run stow --restow --ignore='TODO\.md' -t "$HOME" "$p"
done
