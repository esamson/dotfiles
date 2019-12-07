jaeger_home=$HOME/.local/opt/jaeger
if [ -f $jaeger_home/jaeger-all-in-one ]; then
    pathmunge $jaeger_home after
fi
unset jaeger_home
