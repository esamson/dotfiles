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
unset script

# vi mode command prompt
set -o vi

PS1="[\[\033[36m\]\u\[\033[m\]@\h \[\033[32m\]\W\[\033[m\]]\$ "

HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Homebrew bash completion
#source $(brew --repository)/Library/Contributions/brew_bash_completion.sh
if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
    . $(brew --prefix)/share/bash-completion/bash_completion
fi

