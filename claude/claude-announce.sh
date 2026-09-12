#!/bin/bash
# usage: claude-announce.sh done|waiting  (Stop and Notification hooks)
mode=${1:-done}
input=$(cat)
sid=$(jq -r .session_id <<<"$input")

name=unnamed
tmuxloc=""
f=$(grep -l "$sid" ~/.claude/sessions/*.json 2>/dev/null | head -1)
if [ -n "$f" ]; then
    name=$(jq -r '.name // "unnamed"' "$f")
    tmuxloc=$(jq -r '.tmux // ""' "$f")
fi

# TMUX_PANE (inherited from the claude process) survives window moves; the
# registry's tmux field is the fallback for sessions started without it
pane="${TMUX_PANE:-}"
[ -z "$pane" ] && [ -n "$tmuxloc" ] && pane=${tmuxloc##*.}
if [ -n "$pane" ]; then
    win=$(tmux display-message -p -t "$pane" '#{window_id}' 2>/dev/null)
    # a bell flags the window (styled red by window-status-bell-style) until it is visited
    ptty=$(tmux display-message -p -t "$pane" '#{pane_tty}' 2>/dev/null)
    [ -n "$ptty" ] && [ -w "$ptty" ] && printf '\a' > "$ptty"
    [ -n "$win" ] && (
        for i in 1 2 3 4 5; do
            tmux set-option -w -t "$win" window-status-style 'bg=red,fg=white,bold'
            tmux set-option -w -t "$win" window-status-current-style 'bg=red,fg=white,bold'
            sleep 0.25
            tmux set-option -w -u -t "$win" window-status-style
            tmux set-option -w -u -t "$win" window-status-current-style
            sleep 0.25
        done
    ) &
fi

if [ "$mode" = waiting ]; then
    sound=Basso
    ntype=$(jq -r '.notification_type // ""' <<<"$input")
    case $ntype in
        permission_prompt) msg="Hey bro, I need your permission in session '${name//-/ }'" ;;
        idle_prompt)       msg="Hey bro, I'm still waiting for you in session '${name//-/ }'" ;;
        *)                 msg="Hey bro, I'm waiting for you in session '${name//-/ }'" ;;
    esac
else
    sound=Hero
    msg="I'm done in session '${name//-/ }'"
fi

afplay "/System/Library/Sounds/$sound.aiff" &

esc=$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
hs -c "hs.alert.show(\"$esc\", { textSize = 20, radius = 12 }, hs.screen.mainScreen(), 5)" >/dev/null 2>&1 &
say "$msg" &
