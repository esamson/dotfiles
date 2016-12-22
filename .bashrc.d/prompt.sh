source ~/.local/lib/git-prompt.sh

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWCOLORHINTS=1
PROMPT_COMMAND='__git_ps1 "[\[\033[36m\]\u\[\033[m\]@\h \[\033[32m\]\W\[\033[m\]]" "\\\$ " "[%s]"'
