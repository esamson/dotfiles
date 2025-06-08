# dotfiles
.files

Taking management ideas from [www.atlassian.com/git/tutorials/dotfiles][archive].

## On a new machine

Clone this repo and run the sync script.

```
git clone git@github.com:esamson/dotfiles.git
sh dotfiles/.local/bin/sync_dotfiles.sh
```

This sets up the actual clone in `$HOME/.dotfiles`.
Actual management happens from there. The above clone is only for setup.

[archive]: https://web.archive.org/web/20250531183126/https://www.atlassian.com/git/tutorials/dotfiles
