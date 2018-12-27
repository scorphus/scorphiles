# path
set -gx PATH /usr/local/sbin $HOME/.local/bin $PATH

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

# Path to your oh-my-fish.
set -g OMF_PATH $HOME/.local/share/omf

# Path to your oh-my-fish configuration.
set -g OMF_CONFIG $HOME/.config/omf

# iTerm2 Shell Integration
# https://iterm2.com/documentation-shell-integration.html

### Configuration required to load oh-my-fish ###
# Note: Only add configurations that are required to be set before oh-my-fish
# is loaded. For common configurations, we advise you to add them to your
# $OMF_CONFIG/init.fish file or to create a custom plugin instead.

# z omf pkg config
set -g Z_SCRIPT_PATH /usr/local/etc/profile.d/z.sh

# gem omf pkg config
set -x GEM_ROOT $HOME/.gem

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

# Load aliases
source $HOME/.config/fish/aliases.fish
