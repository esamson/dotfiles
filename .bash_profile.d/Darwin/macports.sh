if [ -x /opt/local/bin/port ]; then
    pathmunge /opt/local/bin

    if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
        . /opt/local/etc/profile.d/bash_completion.sh

        # There might be a better way to do this but this works for now.
        if [ -f /opt/local/share/git/contrib/completion/git-completion.bash ]; then
            . /opt/local/share/git/contrib/completion/git-completion.bash
        fi
    fi
fi
