#!/usr/bin/env bash

brew install tmux

# Make pasteboard work for tmux in macOS Sierra
# https://github.com/tmux/tmux/issues/543
brew install reattach-to-user-namespace --with-wrap-pbcopy-and-pbpaste
