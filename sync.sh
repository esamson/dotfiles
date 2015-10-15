#!/usr/bin/env bash
 
cd "$(dirname "${BASH_SOURCE}")"

# Copy existing dotfiles into this repo
function syncDown() {
    TMPFILE=`mktemp -t syncup` || exit 1
    if [ $? -ne 0 ]; then
        echo "$0: Can't create temp file, exiting..."
        exit 1
    fi

    find . -type f \
        -not -path './.git*' \
        -not -path './LICENSE' \
        -not -path './README.md' \
        -not -path './sync.sh' \
        | sed "s|^\./||" > $TMPFILE

    rsync \
        --files-from $TMPFILE \
        --verbose \
        --human-readable \
        --archive ~ .

    rm $TMPFILE
    git diff
}

# Install dotfiles into home folder
function syncUp() {
    rsync \
        --exclude ".git/" \
        --exclude "LICENSE" \
        --exclude "README.md" \
        --exclude "sync.sh" \
        --verbose \
        --human-readable \
        --archive . ~
    source ~/.bash_profile
}

if [ "$1" == "-d" ]; then
    syncDown;
else
    syncUp;
fi;
