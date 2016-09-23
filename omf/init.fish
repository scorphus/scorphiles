# virtualfish
set -g PROJECT_HOME $HOME/Workspace
set -g VIRTUALFISH_COMPAT_ALIASES
set -l vf_plugins auto_activation compat_aliases global_requirements projects
set -l vf_loader (python -m virtualfish $vf_plugins ^ /dev/null)
if test -n "$vf_loader"
    eval $vf_loader
    if test "$VIRTUAL_ENV" != ""; and type -q vf
        vf activate (basename $VIRTUAL_ENV) 2>&1 > /dev/null
    end
end

# scorphish theme
set -g SCORPHISH_GIT_INFO_ON_FIRST_LINE
set -g theme_display_rust yes
set -g theme_display_nvm yes

# set sensitive variables
source $OMF_CONFIG/sensitive.fish ^/dev/null
