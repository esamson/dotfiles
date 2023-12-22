local_dev="$HOME/Documents/local-dev"
if [ -d "$local_dev/bash_profile.d" ]; then
    for script in $local_dev/*.sh ; do
        if [ -r $script ] ; then
            . $script
        fi
    done
    unset script
fi

if [ -d "$local_dev/bin" ]; then
    pathmunge "$local_dev/bin" after
fi

unset local_dev
