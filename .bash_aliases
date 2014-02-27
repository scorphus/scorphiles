# Alias definitions.
# Separate file ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# Python Virtualenvs
alias venvone='source ~/Virtualenvs/one/bin/activate'
alias venvtwo='source ~/Virtualenvs/two/bin/activate'

# Screens
alias screen-can='cd ~/Workspaces/Sublime/donejs; screen -S canjs -t can'
alias screen-ks='cd ~/Workspaces/Sublime/klicksite; screen -S klicksite -t ks'

# Screens with Virtualenv!
alias screen-mv='cd ~/Workspaces/Sublime/movimente.me; VENV="source /home/scorphus/Virtualenvs/two/bin/activate" screen -S movimente -t mv'
alias screen-hlm-api='cd ~/Workspaces/Sublime/holmes-api; VENV="source /home/scorphus/Virtualenvs/two/bin/activate" screen -S holmes-api -t hlm-api'
alias screen-hlm-web='cd ~/Workspaces/Sublime/holmes-web; VENV="source /home/scorphus/Virtualenvs/two/bin/activate" screen -S holmes-web -t hlm-web'
