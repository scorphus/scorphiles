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
    # a bell flags the window (the tmux window formats paint it red) until it is visited
    ptty=$(tmux display-message -p -t "$pane" '#{pane_tty}' 2>/dev/null)
    [ -n "$ptty" ] && [ -w "$ptty" ] && printf '\a' > "$ptty"
    # @flash makes the window formats blink the window's capsule
    [ -n "$win" ] && (
        for i in 1 2 3 4 5; do
            tmux set-option -w -t "$win" @flash 1
            sleep 0.25
            tmux set-option -w -u -t "$win" @flash
            sleep 0.25
        done
    ) &
fi

if [ "$mode" = waiting ]; then
    sound=Basso
    ntype=$(jq -r '.notification_type // ""' <<<"$input")
    case $ntype in
        permission_prompt) msg="Need permission in session '${name//-/ }'" ;;
        idle_prompt)       msg="Still waiting in session '${name//-/ }'" ;;
        *)                 msg="Waiting in session '${name//-/ }'" ;;
    esac
else
    sound=Hero
    msg="Done in session '${name//-/ }'"
fi

# set from the Hammerspoon menubar: no file = sound and speech, "ping" = sound
# only, "mute" = neither; the tmux flag/flash and the overlay stay on in all three
mode=$(cat ~/.claude/announce-mode 2>/dev/null)

[ "$mode" = mute ] || afplay "/System/Library/Sounds/$sound.aiff" &

esc=$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
hs -c "hs.alert.show(\"$esc\", { textSize = 20, radius = 12 }, hs.screen.mainScreen(), 5)" >/dev/null 2>&1 &
[ "$mode" = mute ] || [ "$mode" = ping ] || say "$msg" &
