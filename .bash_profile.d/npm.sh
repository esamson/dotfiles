# https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally
if hash npm 2>/dev/null; then
    export NPM_CONFIG_PREFIX=$HOME/.local/npm
    mkdir -p "$NPM_CONFIG_PREFIX"
    pathmunge "$NPM_CONFIG_PREFIX/bin" after
fi
