#!/usr/bin/env bash

brew_fzf="$HOME/.fzf.bash"
fedora_fzf=/usr/share/fzf/shell/key-bindings.bash

if [ -f "$brew_fzf" ]; then
    fzf_bash=$brew_fzf
else
    fzf_bash=$fedora_fzf
fi

if [ -f "$fzf_bash" ] ; then
    source $fzf_bash
fi
