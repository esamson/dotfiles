JAVA_HOME="$(/usr/libexec/java_home)"
if [ -f $JAVA_HOME/bin/javac ]; then
    pathmunge "$JAVA_HOME/bin"
    export JAVA_HOME
fi
