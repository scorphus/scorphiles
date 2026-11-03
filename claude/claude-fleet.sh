#!/bin/bash
# one segment per live Claude Code session, for tmux status-right; also sets
# @claude busy|idle on each window running a session, for the window formats;
# drops the least recently active sessions that do not fit beside the windows
entries=""
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
    updated=$(jq -r '.statusUpdatedAt // 0' "$f")
    entries+="$updated ${#name} $dot ${name:0:12}  "$'\n'

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

# what the rest of the status line takes: session name, window capsules, clock
session=$(tmux display-message -p '#S')
used=$(( ${#session} + 3 + 18 ))
while read -r w; do
    used=$(( used + ${#w} + 3 ))
done < <(tmux list-windows -F '#I#W')
room=$(( $(tmux display-message -p '#{client_width}') - used ))
out=""
while read -r _ len entry; do
    [ -n "$entry" ] || continue
    (( len > 12 )) && len=12
    room=$(( room - len - 4 ))
    (( room >= 0 )) || break
    out+="$entry  "
done < <(printf '%s' "$entries" | sort -rn)
printf '%s' "$out"
