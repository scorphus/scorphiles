#!/bin/bash
# pop a tmux menu of live Claude Code sessions; picking one jumps to its window
#   --choose <pane>  only the Claudes in that pane's window, for fish's `ask`: a single one is
#                    printed, several make the menu, where picking one types `ask %<pane>` there
args=(-T "Claude sessions")
shell=""
if [ "${1:-}" = --choose ]; then
    shell=$2
    here=$(tmux display -p -t "$shell" '#{window_id}')
    args=(-T "Claude in this window")
    found=()
fi
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
    if [ -n "$shell" ]; then
        pane=${tmuxloc##*.}
        [ -n "$tmuxloc" ] && [ "$(tmux display -p -t "$pane" '#{window_id}' 2>/dev/null)" = "$here" ] || continue
        found+=("$pane")
        args+=("$dot $name  pane ${pane#%}" "$i" "send-keys -t '$shell' 'ask $pane' Enter")
        i=$((i+1))
        continue
    fi
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
if [ -n "$shell" ] && [ "${#found[@]}" -le 1 ]; then
    [ "${#found[@]}" -eq 1 ] && echo "${found[0]}"
    exit 0
fi
tmux display-menu "${args[@]}"
