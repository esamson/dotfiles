# Homebrew bash completion
if hash brew 2>/dev/null; then
    bash_completion="$(brew --prefix)/etc/profile.d/bash_completion.sh"
    if [ -r "$bash_completion" ]; then
        export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
        source "$bash_completion"
    fi

    homebrew_github_api_token="$HOME/.homebrew_github_api_token"
    if [ -r "$homebrew_github_api_token" ]; then
        export HOMEBREW_GITHUB_API_TOKEN="$(cat $homebrew_github_api_token)"
    fi

    export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
fi
