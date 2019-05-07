local_dev="$HOME/Documents/local-dev/bash_profile.d"
if [ -d "$local_dev" ]; then
    for script in $local_dev/*.sh ; do
        if [ -r $script ] ; then
            . $script
        fi
    done
    unset script
fi
unset local_dev
