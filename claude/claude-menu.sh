#!/bin/bash
# pop a tmux menu of live Claude Code sessions; picking one jumps to its window
args=(-T "Claude sessions")
i=1
for f in ~/.claude/sessions/*.json; do
    [ -e "$f" ] || continue
    pid=$(jq -r '.pid // 0' "$f")
    kill -0 "$pid" 2>/dev/null || continue
    name=$(jq -r '.name // "?"' "$f")
    status=$(jq -r '.status // ""' "$f")
    tmuxloc=$(jq -r '.tmux // ""' "$f")
    case $status in
        busy)  dot="#[fg=green,bold]●#[default]" ;;
        wait*) dot="#[fg=red,bold]●#[default]" ;;
        *)     dot="#[fg=colour245]○#[default]" ;;
    esac
    # an entry with no command shows dimmed and cannot be picked
    cmd=""
    if [ -n "$tmuxloc" ]; then
        sess=${tmuxloc%%:*}
        t=${tmuxloc#*:}
        win=${t%.*}
        cmd="switch-client -t '$sess' ; select-window -t '$sess:$win'"
    fi
    args+=("$dot $name" "$i" "$cmd")
    i=$((i+1))
done
tmux display-menu "${args[@]}"
