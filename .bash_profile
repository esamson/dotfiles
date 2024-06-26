# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

pathmunge () {
    if ! echo $PATH | /usr/bin/grep -E -q "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH=$PATH:$1
        else
            PATH=$1:$PATH
        fi
    fi
}

# User specific environment and startup programs

OPT=$HOME/.local/opt

export GPG_TTY=$(tty)
export TMOUT=0

if hash nvim 2>/dev/null; then
    export EDITOR=nvim
elif hash vim 2>/dev/null; then
    export EDITOR=vim
fi

for script in ~/.bash_profile.d/$(uname)/*.sh ; do
    if [ -r $script ] ; then
        . $script
    fi
done
for script in ~/.bash_profile.d/*.sh ; do
    if [ -r $script ] ; then
        . $script
    fi
done
unset script

pathmunge /usr/local/sbin after
pathmunge $HOME/.local/bin
pathmunge $HOME/bin

# OS-specific executables
if [ -d "$HOME/.local/bin/$(uname)" ]; then
    pathmunge "$HOME/.local/bin/$(uname)"
fi

export PATH

LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8

