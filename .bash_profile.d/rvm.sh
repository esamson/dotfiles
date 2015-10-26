# Add RVM to PATH for scripting
RVM_HOME=$HOME/.rvm
if [ -d $RVM_HOME ] ; then
    pathmunge $RVM_HOME/bin after
fi
