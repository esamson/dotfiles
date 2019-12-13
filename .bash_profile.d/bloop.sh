bloop_home="$HOME/.bloop"
if [ -f "$bloop_home/bloop" ]; then
    pathmunge "$bloop_home" after
    source $bloop_home/bash/bloop
fi
unset bloop_home
