# path
set -gx PATH $HOME/.local/bin $PATH /usr/local/sbin

# golang
set -gx GOPATH $HOME/gocode
set -gx GOBIN $GOPATH/bin
set -gx PATH $GOBIN $PATH

# general purpose scripts
# set -x PATH $HOME/bin $PATH
for dir in (find $HOME/bin/ -mindepth 1 -maxdepth 1 -type d)
    set -x PATH $dir $PATH
end

# Python stuff
set -xg PYTHONDONTWRITEBYTECODE 1  # Don't write bytecode files everywhere

# TheFuck stuff
set -xg TF_OVERRIDDEN_ALIASES 'cd,grep,ls,man,open,git'

# z omf pkg config
set -g Z_SCRIPT_PATH /usr/local/etc/profile.d/z.sh

# gem omf pkg config
set -x GEM_ROOT $HOME/.gem
