if [ -x /opt/local/bin/port ]; then
    pathmunge /opt/local/bin

    if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
        . /opt/local/etc/profile.d/bash_completion.sh
    fi
fi
