# Prefer python from Homebrew if it is available
python_bin=/usr/local/opt/python/libexec/bin
if [ -f $python_bin/python ]; then
    pathmunge $python_bin
fi
unset python_bin
