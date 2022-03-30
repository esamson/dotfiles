cargo_home="$HOME/.cargo"
if [ -d $cargo_home/bin ]; then
    export CARGO_HOME="$cargo_home"
    pathmunge $CARGO_HOME/bin
fi
unset cargo_home
