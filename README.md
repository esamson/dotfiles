# dotfiles
.files

Taking management ideas from [www.atlassian.com/git/tutorials/dotfiles][archive].

## On a new machine

```
git clone --bare git@github.com:esamson/dotfiles.git "$HOME/.dotfiles"
git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no
```

[archive]: https://web.archive.org/web/20250531183126/https://www.atlassian.com/git/tutorials/dotfiles
