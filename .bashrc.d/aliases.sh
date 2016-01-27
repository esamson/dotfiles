# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag="-G"
fi

alias la="ls -laF ${colorflag}"
alias ll="ls -lF ${colorflag}"
alias ls="ls -F ${colorflag}"
 
alias gpg=gpg2

alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'

# Alias macvim to gvim
if [ "$(uname)" == "Darwin" ]; then
    alias gvim=mvim
fi
