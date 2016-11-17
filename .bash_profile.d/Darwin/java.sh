jdk_ln=$HOME/.local/opt/jdk

if [ ! -L $jdk_ln ]; then
    ln -s "$(/usr/libexec/java_home)" "$jdk_ln"
fi

export JAVA_HOME="$jdk_ln"
pathmunge $JAVA_HOME/bin
