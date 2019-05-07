# Homebrew bash completion
if hash brew 2>/dev/null; then
    bash_completion="$(brew --prefix)/etc/profile.d/bash_completion.sh"
    if [ -r "$bash_completion" ]; then
        export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
        source "$bash_completion"
    fi
fi
