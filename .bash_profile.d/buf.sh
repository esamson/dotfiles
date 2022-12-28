# https://github.com/bufbuild/buf
buf_home=$HOME/.local/opt/buf
if [ -f $buf_home/bin/buf ]; then
    pathmunge $buf_home/bin after
    source $buf_home/etc/bash_completion.d/buf
    export MANPATH="$buf_home/share/man:$MANPATH"
fi
unset buf_home
