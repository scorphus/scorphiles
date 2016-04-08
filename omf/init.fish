# virtualfish
set -g PROJECT_HOME $HOME/Workspace
set -g VIRTUALFISH_COMPAT_ALIASES
eval (python -m virtualfish auto_activation compat_aliases global_requirements projects)
if test "$VIRTUAL_ENV" != ""
    vf activate (basename $VIRTUAL_ENV)
end

# golang
set -g GOPATH $HOME/gocode
set -x PATH $GOPATH/bin $PATH

# general purpose scripts
set -x PATH $HOME/bin $PATH

for dir in (basename (find $HOME/bin/ -type d -depth 1))
    set -x PATH $HOME/bin/$dir $PATH
end

# scorphish theme
set -g SCORPHISH_GIT_INFO_ON_FIRST_LINE

# set sensitive variables
source $OMF_CONFIG/sensitive.fish ^/dev/null

# Python stuff
set -g PYTHONDONTWRITEBYTECODE 1  # Don't write bytecode files everywhere
