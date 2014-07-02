# Alias definitions.
# Separate file ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# Python Virtualenvs
# alias venvone='source ~/Virtualenvs/one/bin/activate'
# alias venvtwo='source ~/Virtualenvs/two/bin/activate'

# Screens
# alias screen-can='cd ~/Workspaces/Sublime/donejs; screen -S canjs -t can'
# alias screen-ks='cd ~/Workspaces/Sublime/klicksite; screen -S klicksite -t ks'
#alias screen-glb='screen -S glb -t x'

# Screens with Virtualenv!
# alias screen-mv='cd ~/Workspaces/Sublime/movimente.me; VENV="source /home/scorphus/Virtualenvs/two/bin/activate" screen -S movimente -t mv'
# alias screen-hlm-api='cd ~/Workspaces/Sublime/holmes-api; VENV="source /home/scorphus/Virtualenvs/two/bin/activate" screen -S holmes -t hlm-api'

# ls
alias ll='ls -Glh'
alias la='ls -GAh'
alias lt='ls -Glhtr'
alias lat='ls -GlAhtr'
alias lah='ls -GlAh'
alias lan='ls -GlAhnr'
alias l='ls -GCFh'
alias ls='ls -G'

# grep
alias rgrep="grep -r --color"
alias egrep="egrep --color"
alias grep="grep --color"

# sed
alias sed="/usr/local/opt/gnu-sed/libexec/gnubin/sed"
