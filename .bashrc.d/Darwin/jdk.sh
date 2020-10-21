# Switch JDK

jdk_ln=$HOME/.local/opt/jdk

jdk() {
    rm -f "$jdk_ln"
    ln -s "$(/usr/libexec/java_home -v $1)" "$jdk_ln"
}
