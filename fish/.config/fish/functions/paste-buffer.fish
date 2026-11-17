function paste-buffer --description 'Paste from clipboard (portable)'
    # In tmux, paste directly into the pane for best fidelity
    if set -q TMUX; and type -q tmux
        tmux paste-buffer -p
        return $status
    end

    # Otherwise, read from the system clipboard using available tools
    set -l data ""
    if type -q pbpaste
        set data (pbpaste)
    else if type -q wl-paste
        set data (wl-paste)
    else if type -q xclip
        set data (xclip -o -selection clipboard)
    else if type -q xsel
        set data (xsel --clipboard --output)
    else if type -q termux-clipboard-get
        set data (termux-clipboard-get)
    else if type -q powershell.exe
        set data (powershell.exe -NoProfile -Command Get-Clipboard)
    else
        # No known clipboard reader found
        return 1
    end

    # Join into a single string and strip a single trailing newline
    set data (string join \n $data)
    set data (string replace -r '\r?\n$' '' -- $data)

    if status is-interactive
        # Insert into the current command line
        commandline -i -- $data
    else
        # Non-interactive: write to stdout
        printf "%s" -- $data
    end
end
