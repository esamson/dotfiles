#!/usr/bin/env bash
#
# Change the Screenshot save location
# http://osxdaily.com/2011/01/26/change-the-screenshot-save-file-location-in-mac-os-x/

defaults write com.apple.screencapture location $HOME/Downloads
killall SystemUIServer
