# virtualfish
set -g PROJECT_HOME $HOME/Workspace
set -g VIRTUALFISH_COMPAT_ALIASES
eval (python -m virtualfish auto_activation compat_aliases global_requirements projects)
if test "$VIRTUAL_ENV" != ""
    vf activate (basename $VIRTUAL_ENV)
end

# scorphish theme
set -g SCORPHISH_GIT_INFO_ON_FIRST_LINE

# set sensitive variables
source $OMF_CONFIG/sensitive.fish ^/dev/null
