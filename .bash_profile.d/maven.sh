maven_home=$HOME/.local/opt/maven
if [ -f $maven_home/bin/mvn ]; then
    pathmunge $maven_home/bin after
fi
unset maven_home
