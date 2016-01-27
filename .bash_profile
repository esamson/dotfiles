# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

pathmunge () {
    if ! echo $PATH | /usr/bin/egrep -q "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH=$PATH:$1
        else
            PATH=$1:$PATH
        fi
    fi
}

# User specific environment and startup programs

OPT=$HOME/.local/opt

pathmunge $HOME/.local/bin
pathmunge $HOME/bin
pathmunge /usr/local/sbin after

export GPG_TTY=$(tty)
export TMOUT=0
export EDITOR=vim

for script in ~/.bash_profile.d/*.sh ; do
    if [ -r $script ] ; then
        . $script
    fi
done
for script in ~/.bash_profile.d/$(uname)/*.sh ; do
    if [ -r $script ] ; then
        . $script
    fi
done
unset script

export PATH

LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8

