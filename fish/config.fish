# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

# Path to your custom folder (default path is ~/.oh-my-fish/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# virtualfish
set PROJECT_HOME $HOME/Workspace
set VIRTUALFISH_COMPAT_ALIASES
eval (python -m virtualfish auto_activation compat_aliases global_requirements projects)

# Go
set -x GOPATH $HOME/gocode
set -x PATH $GOPATH/bin $PATH

# general purpose scripts
set -x PATH $HOME/bin $PATH

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish

# OMF Theme
set SCORPHISH_GIT_INFO_ON_FIRST_LINE
Theme 'scorphish'

# OMF Plugins
Plugin 'bundler'
Plugin 'gem'
Plugin 'gi'
Plugin 'node'
Plugin 'osx'
Plugin 'peco'
Plugin 'python'
Plugin 'rvm'
Plugin 'sublime'
Plugin 'theme'
Plugin 'z'
