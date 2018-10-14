scala_home="$HOME/.local/opt/scala"
if [ -f "$scala_home/bin/scalac" ]; then
    export SCALA_HOME="$scala_home"
    pathmunge "$scala_home/bin" after
fi
unset scala_home
