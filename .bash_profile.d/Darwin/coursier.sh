# Coursier
# https://get-coursier.io/docs/cli-installation

coursier_bin="$HOME/Library/Application Support/Coursier/bin"
if [ -d "$coursier_bin" ]; then
    pathmunge "$coursier_bin" after
fi
unset coursier_bin
