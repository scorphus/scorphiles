function load-buffer --description 'Copy stdin to clipboard (portable)'
    # Read all stdin into a single variable
    read -z -l data

    # Prefer tmux first for consistent remote/local behavior
    if set -q TMUX; and type -q tmux
        # Try tmux clipboard passthrough (-w); fallback to buffer only
        printf "%s" "$data" | tmux load-buffer -w - 2>/dev/null
        or printf "%s" "$data" | tmux load-buffer -
    else if type -q pbcopy
        printf "%s" "$data" | pbcopy
    else if type -q wl-copy
        printf "%s" "$data" | wl-copy
    else if type -q xclip
        printf "%s" "$data" | xclip -selection clipboard
    else if type -q xsel
        printf "%s" "$data" | xsel --clipboard --input
    else if type -q termux-clipboard-set
        printf "%s" "$data" | termux-clipboard-set
    else if type -q clip.exe
        printf "%s" "$data" | clip.exe
    else if type -q powershell.exe
        printf "%s" "$data" | powershell.exe -NoProfile -Command Set-Clipboard
    else
        # OSC 52 fallback: write directly to the terminal device
        set -l b64 (printf "%s" "$data" | base64 | tr -d '\r\n')
        printf "\e]52;c;%s\a" "$b64" > /dev/tty
    end
end
