java_home_opts=""
opts_file=$HOME/.java_home_opts
if [ -r $opts_file ]; then
    source $opts_file
fi
export JAVA_HOME="$(/usr/libexec/java_home $java_home_opts)"
pathmunge $JAVA_HOME/bin
