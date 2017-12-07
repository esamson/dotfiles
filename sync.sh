#!/usr/bin/env bash
 
cd "$(dirname "${BASH_SOURCE}")"

# Copy existing dotfiles into this repo
function syncDown() {
    if [[ -n $(git status -s) ]]; then
        echo "$0: Uncommited changes in dotfiles. Commit them first."
        exit 1
    fi

    crontab -l > crontab

    TMPFILE=`mktemp -t syncup.XXX` || exit 1
    if [ $? -ne 0 ]; then
        echo "$0: Can't create temp file, exiting..."
        exit 2
    fi

    find . -type f \
        -not -path './.git/*' \
        -not -path './.gitmodules' \
        -not -path '*/.git' \
        -not -path './LICENSE' \
        -not -path './README.md' \
        -not -path './crontab' \
        -not -path './bootstrap' \
        -not -path './installers/*' \
        -not -path './sync.sh' \
        | sed "s|^\./||" > $TMPFILE

    rsync \
        --files-from $TMPFILE \
        --verbose \
        --human-readable \
        --archive ~ .

    rm $TMPFILE
    if [[ -n $(git status -s) ]]; then
        echo "$0: Changes found in $HOME. Review and commit."
        git diff
    else
        echo "$0: $HOME is up to date."
    fi
}

# Copy amm scripts
function syncAmmScripts() {
    for sc in amm-scripts/*.sc; do
        name="$(basename ${sc%%.*})"
        target="$HOME/.local/bin/$name"
        echo "#!/usr/bin/env amm" > $target
        cat $sc >> $target
    done
}

# Install dotfiles into home folder
function syncUp() {
    crontab crontab

    rsync \
        --exclude "/.git/" \
        --exclude "/.gitmodules" \
        --exclude "**/.git" \
        --exclude "/LICENSE" \
        --exclude "/README.md" \
        --exclude "/amm-scripts" \
        --exclude "/crontab" \
        --exclude "/bootstrap" \
        --exclude "/installers/" \
        --exclude "/sync.sh" \
        --verbose \
        --human-readable \
        --no-perms \
        --archive . ~

    syncAmmScripts
    chmod go-rwx $HOME
    source ~/.bash_profile
}

if [ "$1" == "-d" ]; then
    syncDown;
else
    syncUp;
fi;
