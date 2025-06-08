# dotfiles command
# see: https://www.atlassian.com/git/tutorials/dotfiles
if [ -d "$HOME/.dotfiles" ]; then
    alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME"'
fi
