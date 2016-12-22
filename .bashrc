# .bashrc

# We only work for interactive shells
if [ -z "$PS1" ]; then
    return
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Load the shell dotfiles:
# For other settings you don’t want to commit, create scripts in ~/.bashrc.d/
for script in ~/.bashrc.d/*.sh ; do
    if [ -r $script ] ; then
        . $script
    fi
done
for script in ~/.bashrc.d/$(uname)/*.sh ; do
    if [ -r $script ] ; then
        . $script
    fi
done
unset script

# vi mode command prompt
set -o vi

HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;
