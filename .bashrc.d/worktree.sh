#!/usr/bin/env bash
#
# Git worktree switcher
#
# Usage:
#     Source this in your .bashrc and call `worktree` in your working
#     directory. Calling with no arguments lists existing worktrees if any.
#     
#     `worktree <name>` changes current directory to named worktree.
#     `worktree --main` changes current directory to main working copy.
#
# TODO:
#     * Work from within any subdirectory of a git working copy.

__worktree_cd() {
    MAIN_DIR=$1
    WORK_TREE=$2

    if [ "--main" == "$WORK_TREE" ] || [ "-m" == "$WORK_TREE" ]; then
        cd $MAIN_DIR
        return
    fi

    if [ ! -d "$MAIN_DIR/.git/worktrees/$WORK_TREE" ]; then
        echo "No such worktree '$WORK_TREE'"
        return 1
    fi

    gitdir=$(cat $MAIN_DIR/.git/worktrees/$WORK_TREE/gitdir)
    dir=$(dirname $gitdir)
    cd $dir
}

__worktree_ls() {
    MAIN_DIR=$1
    echo "Worktrees:"

    for worktree in $MAIN_DIR/.git/worktrees/* ; do
        name=$(basename $worktree)
        dir=$(dirname $(cat $worktree/gitdir))
        echo $'\t'"$name "$'\t'"- $dir"
    done
    echo '`worktree <name>` switches to named worktree'
}

__worktree_in_maindir() {
    if [ ! -d ".git/worktrees" ]; then
        echo "No worktrees"
        return
    fi

    if [ -z "$1" ]; then
        __worktree_ls $PWD
    else
        __worktree_cd $PWD $1
    fi
}

__worktree_in_workdir() {
    MAIN_DIR=$(cat .git | sed 's/gitdir: //' | sed 's/\/\.git.*//')

    if [ -z "$1" ]; then
        echo "In worktree $PWD"
        echo "       from $MAIN_DIR"
        echo '`worktree --main` switches to main dir'
        echo
        __worktree_ls $MAIN_DIR
    else
        __worktree_cd $MAIN_DIR $1
    fi
}

__worktree_complete() {
    local list=""

    if [ -d ".git" ]; then
        MAIN_DIR=$PWD
    elif [ -f ".git" ]; then
        MAIN_DIR=$(cat .git | sed 's/gitdir: //' | sed 's/\/\.git.*//')
        list="--main"
        current_tree=$(cat .git | sed 's/gitdir: //')
    fi

    if [ -z "$MAIN_DIR" ]; then
        COMPREPLY=()
        return
    fi

    if [ ! -d "$MAIN_DIR/.git/worktrees" ]; then
        COMPREPLY=()
        return
    fi

    if [ $COMP_CWORD -gt 1 ]; then
        COMPREPLY=()
        return
    fi

    local cur=${COMP_WORDS[COMP_CWORD]}

    for worktree in $MAIN_DIR/.git/worktrees/* ; do
        if [ "$current_tree" != "$worktree" ]; then
            name=$(basename $worktree)
            if [ -z "$list" ]; then
                list="$name"
            else
                list="$list $name"
            fi
        fi
    done

    COMPREPLY=( $(compgen -W "$list" -- $cur) )
}
 
worktree() {
    if [ -d ".git" ]; then
        __worktree_in_maindir $*
    elif [ -f ".git" ]; then
        __worktree_in_workdir $*
    else
        echo "Not in a git workspace"
        return 1
    fi
}

complete -F __worktree_complete worktree
