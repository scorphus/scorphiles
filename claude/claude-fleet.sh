#!/bin/bash
# one segment per live Claude Code session, for tmux status-right; also sets
# @claude busy|idle on each window running a session, for the window formats
out=""
busy=" "
idle=" "
for f in ~/.claude/sessions/*.json; do
    [ -e "$f" ] || continue
    pid=$(jq -r '.pid // 0' "$f")
    kill -0 "$pid" 2>/dev/null || continue
    name=$(jq -r '.name // "?"' "$f")
    status=$(jq -r '.status // ""' "$f")
    case $status in
        busy)  dot="#[fg=green,bold]●#[default]" ;;
        wait*) dot="#[fg=red,bold]●#[default]" ;;
        *)     dot="#[fg=colour245]○#[default]" ;;
    esac
    out+="$dot ${name:0:12}  "

    pane=$(jq -r '.tmux // ""' "$f")
    win=$(tmux display-message -p -t "${pane##*.}" '#{window_id}' 2>/dev/null) || continue
    [ "$status" = busy ] && busy+="$win " || idle+="$win "
done
for win in $(tmux list-windows -a -F '#{window_id}'); do
    # one busy session makes its window busy
    case $busy$idle in
        *" $win "*) [[ $busy == *" $win "* ]] && s=busy || s=idle
                    tmux set-option -w -t "$win" @claude $s ;;
        *)          tmux set-option -w -u -t "$win" @claude ;;
    esac
done
printf '%s' "$out"
