cargo_home="$HOME/.cargo"
if [ -f $cargo_home/bin/rustc ]; then
    export CARGO_HOME="$cargo_home"
    pathmunge $CARGO_HOME/bin
fi
unset cargo_home
