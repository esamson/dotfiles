idea_home=$HOME/.local/opt/idea-IC
if [ -f $idea_home/bin/idea.sh ]; then
    pathmunge $idea_home/bin after
fi
unset idea_home
