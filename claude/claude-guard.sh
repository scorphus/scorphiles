#!/bin/bash
# command guard, from Michael Borisov's dotfiles
# https://github.com/SecTedd/dotfiles
#
# Licensed under the MIT license:
# http://www.opensource.org/licenses/mit-license
# Copyright (c) 2026 Michael Borisov
#
# Claude Code PreToolUse hook for shell commands (Bash, Monitor, PowerShell): a
# command matching a line of ~/.claude/guard-ask needs your approval (also in
# auto mode), one matching ~/.claude/guard-deny is refused. One extended regex
# per line, # starts a comment. The command is only matched as text, never run.
#
# usage (settings.json): "PreToolUse": [{ "matcher": "Bash|Monitor|PowerShell",
#   "hooks": [{ "type": "command", "command": "bash ~/.claude/claude-guard.sh" }] }]
set -u -o pipefail
ASK=~/.claude/guard-ask
DENY=~/.claude/guard-deny
# set from the Hammerspoon menubar: skips the ask and deny lists, never the push hash
OFF=~/.claude/guard-off

# decide <allow|ask|deny> <reason>: answer Claude Code and stop
decide() {
    jq -n --arg decision "$1" --arg reason "$2" \
        '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $decision, permissionDecisionReason: $reason}}'
    exit 0
}

patterns() { sed -e 's/[[:space:]]*#.*//' -e '/^[[:space:]]*$/d' "$1"; }

# The first part of the command matching a line of the pattern file; exit 1 = no
# match, 2 = a line of the file is not a valid regex
first_match() { printf '%s\n' "$cmd" | /usr/bin/grep -oE -f <(patterns "$1") 2>/dev/null | head -1; }

command -v jq >/dev/null || {
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"guard: jq is missing"}}'
    exit 0
}
input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input") || decide ask "guard: could not read the command"
[ -r "$ASK" ] && [ -r "$DENY" ] || decide ask "guard: ~/.claude/guard-ask or guard-deny is missing"

if [ ! -e "$OFF" ]; then
    match=$(first_match "$DENY"); status=$?
    [ $status -eq 2 ] && decide ask "guard: a line of ~/.claude/guard-deny is not a valid regex"
    [ $status -eq 0 ] && decide deny "guard: never run this (matched ▶ $match ◀ in ~/.claude/guard-deny)"
fi

# git push runs only on the user's "A: <hash>", the hash being the md5 of the current Unix
# time rounded up to the minute: the last message the user typed must carry "A: <hash>"
# for this minute, anywhere in it. A push combined with other commands still asks.
if printf '%s\n' "$cmd" | /usr/bin/grep -qE '\bgit\s+push\b'; then
    transcript=$(jq -r '.transcript_path // ""' <<<"$input")
    said=$(jq -c 'select(.type == "user" and (.isMeta | not)) | .message.content
        | if type == "string" then . else map(select(.type == "text") | .text) | join("\n") end
        | select(length > 0)' "$transcript" 2>/dev/null | tail -1 | jq -r .)
    hash=$(printf '%s\n' "$said" | /usr/bin/grep -oE '\bA:[[:space:]]*[0-9a-f]{32}\b' | head -1 | /usr/bin/grep -oE '[0-9a-f]{32}')
    now=$(date +%s)
    [ -n "$hash" ] && [ "$hash" = "$(printf '%s' $(((now + 59) / 60 * 60)) | md5)" ] ||
        decide deny "guard: git push needs the user's \"A: <hash>\" for this minute; ask the user for it, do not push otherwise"
    case $cmd in
        *[\;\&\|]*) decide ask "guard: confirmed push, but combined with other commands" ;;
    esac
    decide allow "guard: push confirmed by the user's A: hash"
fi

[ -e "$OFF" ] && exit 0
match=$(first_match "$ASK"); status=$?
[ $status -eq 2 ] && decide ask "guard: a line of ~/.claude/guard-ask is not a valid regex"
[ $status -eq 0 ] && decide ask "guard: matched ▶ $match ◀ (~/.claude/guard-ask)"
exit 0
