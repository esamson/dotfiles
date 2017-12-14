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

# Quick access to SBT target directory
# see: ~/.sbt/1.0/tmptarget.sbt
alias tmpsbt='cd /tmp/sbt`pwd`'
alias tmpsbtclean='mv /tmp/sbt`pwd` /tmp/sbt`pwd`/../$RANDOM'

# Create a new alias from the last command
# https://medium.com/the-lazy-developer/an-alias-for-new-aliases-c6500ae0f73e
new-alias() {
    local new_aliases=~/.bashrc.d/new-aliases.sh
    local last_command=$(echo `history |tail -n2 |head -n1` | sed 's/[0-9]* //')
    echo alias $1="'""$last_command""'" >> $new_aliases
    . $new_aliases
}
