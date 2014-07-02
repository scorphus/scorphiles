# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi


##
# Your previous /Users/pablo.aguiar/.profile file was backed up as /Users/pablo.aguiar/.profile.macports-saved_2014-02-06_at_14:02:58
##

# MacPorts Installer addition on 2014-02-06_at_14:02:58: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.


##
# Your previous /Users/pablo.aguiar/.profile file was backed up as /Users/pablo.aguiar/.profile.macports-saved_2014-02-06_at_19:38:30
##

# MacPorts Installer addition on 2014-02-06_at_19:38:30: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.


PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
