# virtualfish
set PROJECT_HOME $HOME/Workspace
set VIRTUALFISH_COMPAT_ALIASES
eval (python -m virtualfish auto_activation compat_aliases global_requirements projects)
if test "$VIRTUAL_ENV" != ""
    vf activate (basename $VIRTUAL_ENV)
end

# golang
set -x GOPATH $HOME/gocode
set -x PATH $GOPATH/bin $PATH

# general purpose scripts
set -x PATH $HOME/bin $PATH

# scorphish theme
set -g SCORPHISH_GIT_INFO_ON_FIRST_LINE

# set sensitive variables
source $OMF_CONFIG/sensitive.fish ^/dev/null
