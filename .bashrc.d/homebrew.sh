# Homebrew bash completion
#source $(brew --repository)/Library/Contributions/brew_bash_completion.sh
if hash brew 2>/dev/null; then
    if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
        . $(brew --prefix)/share/bash-completion/bash_completion
    fi
fi
