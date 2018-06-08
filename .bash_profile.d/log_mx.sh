log_mx=$HOME/.local/opt/LogMX
if [ -f $log_mx/logmx.sh ]; then
    pathmunge $log_mx after

    if [ -x "$log_mx/logmx.command" ]; then
        chmod -x "$log_mx/logmx.command"
    fi
fi
unset log_mx
