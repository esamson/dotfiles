phoenix_home=$HOME/.local/opt/phoenix
if [ -f $phoenix_home/bin/sqlline.py ]; then
    pathmunge $phoenix_home/bin after
fi
unset phoenix_home
