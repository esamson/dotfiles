# Coursier
# https://get-coursier.io/docs/cli-installation

coursier_home="$HOME/.local/share/coursier"
if [ -f "$coursier_home/bin/cs" ]; then
    pathmunge "$coursier_home/bin" after
fi
unset coursier_home
