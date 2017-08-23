# Prevent default MacOS /etc/profile from messing with PATH order in tmux.
#
# see: https://superuser.com/a/583502

if [ -n "$TMUX" ] && [ -f /etc/profile ]; then
    PATH=""
    source /etc/profile
fi
