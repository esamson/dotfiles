#!/usr/bin/env bash
 
cd "$(dirname "${BASH_SOURCE}")"

function installOne() {
    if [ -r "installers/$(uname)/$1.sh" ]; then
        echo "installing $1"
        sh "installers/$(uname)/$1.sh"
    elif [ -r "installers/$1.sh" ]; then
        echo "installing $1"
        sh "installers/$1.sh"
    else
        echo "no installer for $1"
        exit 1
    fi
}

function installAll() {
    for installer in installers/$(uname)/*.sh ; do
        if [ -r $installer ]; then
            sh $installer &
        fi
    done
    for installer in installers/*.sh ; do
        if [ -r $installer ]; then
            sh $installer &
        fi
    done

    wait
}

if [ -n "$1" ]; then
    installOne $1
else
    read -p "Install all? (y/N)" -n 1;
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        installAll
    fi
fi
