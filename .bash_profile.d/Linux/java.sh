java_home=$HOME/.local/opt/jdk
if [ -f $java_home/bin/javac ]; then
    export JAVA_HOME=$java_home
    pathmunge $JAVA_HOME/bin
elif [ -f /usr/bin/javac ]; then
    export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
    pathmunge $JAVA_HOME/bin
fi
unset java_home

if [ -L /etc/alternatives/java_sdk_1.8.0 ]; then
    # For building projects like pekko
    export JAVA_8_HOME=$(readlink -f /etc/alternatives/java_sdk_1.8.0)
fi
