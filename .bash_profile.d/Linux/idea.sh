idea_home=$HOME/.local/opt/idea-IC
if [ -x $idea_home/bin/idea ]; then
    pathmunge $idea_home/bin after
fi
unset idea_home
