#!/bin/bash
# read-only Claude, from Michael Borisov's dotfiles
# https://github.com/SecTedd/dotfiles
#
# Licensed under the MIT license:
# http://www.opensource.org/licenses/mit-license
# Copyright (c) 2026 Michael Borisov
#
# Claude Code PreToolUse hook: while the tmux pane Claude runs in is read-only
# (prefix R sets @claude_readonly on it), edits are refused and a shell command
# runs only if it reads. Every segment of it is checked: one starting with a
# command from ~/.claude/readonly-allow reads, one starting with a command from
# ~/.claude/readonly-deny writes and is refused, as is anything that redirects,
# substitutes or edits in place; a segment matching neither list asks you.
#
# usage (settings.json): "PreToolUse": [{ "matcher": "Edit|Write|NotebookEdit|EnterWorktree|Bash|Monitor|PowerShell",
#   "hooks": [{ "type": "command", "command": "bash ~/.claude/claude-readonly.sh" }] }]
set -u -o pipefail
ALLOW=~/.claude/readonly-allow
DENY=~/.claude/readonly-deny
REASON='read-only mode is on: the user switched it on deliberately (tmux prefix R), so do not write or change anything and do not look for other ways to do it; if you think a change is needed, ask the user to switch read-only mode off'
ASK_REASON='read-only mode is on and this is not on the read-only list (~/.claude/readonly-allow), approve it only if it reads:'
WRITES='--output\b|\bsed\s+-[a-zA-Z]*i|\bsed\b[^;|&]*[/;]\s*w\b|\bsort\b.*\s-o\b|system\('
WRITES="$WRITES"'|\bfind\b.*\s-(exec|execdir|delete|ok|okdir|fprint|fprintf|fls)\b|\bfd\b.*\s(-x|-X|--exec|--exec-batch)\b'
WRITES="$WRITES"'|\b(perl|ruby)\s+-[a-zA-Z]*i|\b(awk|gawk)\b[^;|&]*\bprintf?\b[^;|&]*>'
WRITES="$WRITES"'|\bcurl\b[^;|&]*\s(-[a-zA-Z]*[oOTdFDc]\b|--(data\S*|form|upload-file|output|remote-name|remote-header-name|cookie-jar|dump-header|trace\S*)\b)'
WRITES="$WRITES"'|\bcurl\b[^;|&]*\s(-X|--request|--method)\s+(POST|PUT|PATCH|DELETE)\b'
SUBSTITUTIONS='\$\(|`|<\('

decide() {
    jq -n --arg decision "$1" --arg reason "$2" \
        '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $decision, permissionDecisionReason: $reason}}'
    exit 0
}
deny() { decide deny "$1"; }
ask() { decide ask "$1"; }

pane_is_readonly() {
    [ -n "${TMUX_PANE:-}" ] && [ "$(tmux show-options -pqv -t "$TMUX_PANE" @claude_readonly 2>/dev/null)" = 1 ]
}

patterns() { sed -e 's/[[:space:]]*#.*//' -e '/^[[:space:]]*$/d' "$1"; }

# Redirections to /dev/null or to another descriptor are harmless; any other > writes
without_harmless_redirects() { sed -E 's#[0-9]*>[[:space:]]*/dev/null##g; s#[0-9]*>&[0-9]+##g'; }

# scan segments|nosingle|noquotes: walk the command the way a shell reads quotes.
#   segments  one command per line, split at ; & | outside quotes
#   nosingle  the text without its single-quoted parts (where $( and ` still substitute)
#   noquotes  the text without any quoted part (where > ; | & are literal)
scan() {
    awk -v mode="$1" -v sq="'" '
        function flush() { gsub(/^[ \t]+|[ \t]+$/, "", seg); if (seg != "") print seg; seg = "" }
        {
            seg = ""; quote = ""
            for (i = 1; i <= length($0); i++) {
                c = substr($0, i, 1)
                if (quote != "") {
                    if (c == quote) { quote = ""; if (mode == "segments") seg = seg c }
                    else if (mode == "segments" || (mode == "nosingle" && quote == "\"")) seg = seg c
                    continue
                }
                if (c == sq || c == "\"") { quote = c; if (mode == "segments") seg = seg c; continue }
                if (c == "\\") { if (mode == "segments") seg = seg c substr($0, i + 1, 1); i++; continue }
                if (mode == "segments" && (c == ";" || c == "&" || c == "|")) { flush(); continue }
                seg = seg c
            }
            flush()
        }'
}

# The command a segment runs: leading keywords, assignments, `env`, `xargs` and
# its options, a case label, and git's -C / --no-pager are dropped
command_of_segment() {
    sed -E -e ':again' \
        -e 's/^(\(+ *|\{ +|! +|[A-Za-z0-9_*?.-]+\) +|(then|else|elif|if|while|until|do|time|command|nice|env) +)//' \
        -e 's/^[A-Za-z_][A-Za-z0-9_]*=("[^"]*"|'"'"'[^'"'"']*'"'"'|[^ ]*) +//' \
        -e 's/^xargs( +-[0rtpo]+| +-[InLPsEJ] *[^ ]+)* +//' \
        -e 's/^git +(-C +[^ ]+ +|--no-pager +|-c +[^ ]+ +)+/git /' \
        -e 't again'
}

# 0 = the segment reads, 1 = it writes, 2 = unknown
segment_verdict() {
    local command
    printf '%s\n' "$1" | scan noquotes | /usr/bin/grep -q -e '>' && return 1
    printf '%s\n' "$1" | scan nosingle | /usr/bin/grep -qE -e "$SUBSTITUTIONS" && return 1
    command=$(printf '%s\n' "$1" | command_of_segment)
    [ -z "$command" ] && return 0
    printf '%s\n' "$command" | /usr/bin/grep -qE -f <(patterns "$ALLOW") && return 0
    printf '%s\n' "$command" | /usr/bin/grep -qE -f <(patterns "$DENY") && return 1
    unknown=$1
    return 2
}

# 0 = every segment reads, 1 = one writes, 2 = none writes but one is unknown
command_verdict() {
    local plain segment verdict worst=0
    plain=$(printf '%s\n' "$cmd" | without_harmless_redirects)
    printf '%s\n' "$plain" | /usr/bin/grep -qE -e "$WRITES" && return 1
    while IFS= read -r segment; do
        segment_verdict "$segment"
        verdict=$?
        [ "$verdict" -eq 1 ] && return 1
        [ "$verdict" -gt "$worst" ] && worst=$verdict
    done < <(printf '%s\n' "$plain" | scan segments)
    return "$worst"
}

pane_is_readonly || exit 0
input=$(cat)
case $(jq -r '.tool_name' <<<"$input") in
    Bash | Monitor | PowerShell) ;;
    *) deny "$REASON" ;;
esac
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
[ -r "$ALLOW" ] && [ -r "$DENY" ] || deny "$REASON (and ~/.claude/readonly-allow or readonly-deny is missing)"
unknown=""
command_verdict
case $? in
    0) exit 0 ;;
    1) deny "$REASON" ;;
    *) ask "$ASK_REASON $unknown" ;;
esac
