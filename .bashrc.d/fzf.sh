#!/usr/bin/env bash

fzf_bindings=/usr/share/fzf/shell/key-bindings.bash
if [ -f "$fzf_bindings" ] ; then
    source $fzf_bindings
fi
