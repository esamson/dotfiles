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

GOPATH=$HOME/.local

HBASE_HOME="$OPT/hbase"
JAVA_HOME="$(/usr/libexec/java_home -v 1.7)"

pathmunge $HOME/.local/bin
pathmunge $HOME/bin
pathmunge $JAVA_HOME/bin
pathmunge /usr/local/sbin after
pathmunge $HBASE_HOME/bin after
# Add RVM to PATH for scripting
pathmunge $HOME/.rvm/bin after

export PATH
export JAVA_HOME
export GOPATH
export GPG_TTY=$(tty)
export TMOUT=0
export EDITOR=vim

LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8

