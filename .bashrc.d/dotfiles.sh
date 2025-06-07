# dotfiles command
# see: https://www.atlassian.com/git/tutorials/dotfiles
dotfiles_dir="$HOME/.dotfiles"
if [ -d "$dotfiles_dir" ]; then
    alias dotfiles='/usr/bin/git --git-dir=$dotfiles_dir --work-tree=$HOME'
fi
unset dotfiles_dir
