# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

# Theme
set SCORPHISH_GIT_INFO_ON_FIRST_LINE
set fish_theme scorphish

# All built-in plugins can be found at ~/.oh-my-fish/plugins/
# Custom plugins may be added to ~/.oh-my-fish/custom/plugins/
# Enable plugins by adding their name separated by a space to the line below.
set fish_plugins bundler emoji-clock gem gi node osx peco python rvm sublime theme z

# Path to your custom folder (default path is ~/.oh-my-fish/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# virtualfish
set PROJECT_HOME $HOME/Workspace
set VIRTUALFISH_COMPAT_ALIASES
eval (python -m virtualfish auto_activation compat_aliases global_requirements projects)

# Go
set -x GOPATH $HOME/gocode
set -x PATH $PATH $GOPATH/bin

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish
