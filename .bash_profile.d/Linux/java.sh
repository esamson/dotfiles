java_home=$HOME/.local/opt/jdk
if [ -f $java_home/bin/javac ]; then
    export JAVA_HOME=$java_home
    pathmunge $JAVA_HOME/bin
fi
unset java_home
