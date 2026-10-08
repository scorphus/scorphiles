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

if [ -n "${TMUX:-}" ]; then
    # inside tmux: TMUX_PANE (inherited from the claude process) survives
    # window moves; the registry's tmux field is the fallback for sessions
    # started before TMUX_PANE was recorded
    pane="${TMUX_PANE:-}"
    [ -z "$pane" ] && [ -n "$tmuxloc" ] && pane=${tmuxloc##*.}
    if [ -n "$pane" ]; then
        win=$(tmux display-message -p -t "$pane" '#{window_id}' 2>/dev/null)
        ptty=$(tmux display-message -p -t "$pane" '#{pane_tty}' 2>/dev/null)
        [ -n "$ptty" ] && [ -w "$ptty" ] && printf '\a' > "$ptty"
        # a bell flags the window (styled red by window-status-bell-style) until it is visited
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
else
    # no tmux: ring the bell on this process's own controlling tty directly,
    # so whatever terminal you're in (Ghostty, iTerm2, Terminal.app, ...) can
    # flag its own tab the way it knows how — there's no window to flash here
    ptty=$(ps -o tty= -p $$ 2>/dev/null | tr -d ' ')
    [ -n "$ptty" ] && [ "$ptty" != "??" ] && ptty="/dev/$ptty"
    [ -n "$ptty" ] && [ -w "$ptty" ] && printf '\a' > "$ptty"
fi

if [ "$mode" = waiting ]; then
    sound=Basso
    ntype=$(jq -r '.notification_type // ""' <<<"$input")
    case $ntype in
        permission_prompt) msg="Need your permission in ${name//-/ }" ;;
        idle_prompt)       msg="Still waiting for you in ${name//-/ }" ;;
        *)                 msg="Waiting for you in ${name//-/ }" ;;
    esac
else
    sound=Hero
    msg="I'm done in ${name//-/ }"
fi

# the Hammerspoon menubar toggle creates this flag; muted = no sound and no
# speech, but the tmux flag/flash and the overlay above stay on
mute=~/.claude/announce-muted

[ -e "$mute" ] || afplay "/System/Library/Sounds/$sound.aiff" &

esc=$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
hs -c "hs.alert.show(\"$esc\", { textSize = 20, radius = 12 }, hs.screen.mainScreen(), 5)" >/dev/null 2>&1 &
[ -e "$mute" ] || say -r100 "$msg" &
