#!/usr/bin/env bash
#
# Git root switcher.
# If current durectory is within a Git repo, `cd` to the top of the repository.
#
# Usage:
#     Source this in your .bashrc and call `groot` from anywhere in your
#     working directory.

groot() {
    gitdir=$(git rev-parse --show-toplevel)
    if [ $? -eq 0 ]; then
        cd $gitdir
    fi
}
