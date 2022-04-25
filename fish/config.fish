if status is-interactive
    # path
    set -gx PATH $HOME/.local/bin $PATH /usr/local/sbin

    # golang
    set -gx GOPATH $HOME/gocode
    set -gx GOBIN $GOPATH/bin
    set -gx PATH $GOBIN $PATH

    # general purpose scripts
    for dir in (find -H $HOME/bin -maxdepth 1 -type d | sort)
        set -x PATH $dir $PATH
    end

    # Python stuff
    set -xg PYTHONDONTWRITEBYTECODE 1  # Don't write bytecode files everywhere

    # TheFuck stuff
    set -xg THEFUCK_OVERRIDDEN_ALIASES 'aws,cd,git,grep,ls,man,open,pyenv'

    # z omf pkg config
    set -g Z_SCRIPT_PATH /usr/local/etc/profile.d/z.sh
    test -f $Z_SCRIPT_PATH
        or set -g Z_SCRIPT_PATH /opt/homebrew/etc/profile.d/z.sh

    # gem omf pkg config
    set -x GEM_ROOT $HOME/.gem
end
