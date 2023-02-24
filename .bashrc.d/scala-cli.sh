# Running `scala-cli install completions`
# would add this into ~/.bashrc 

if hash scala-cli 2>/dev/null; then
    _scala-cli_completions() {
      local IFS=$'\n'
      eval "$(scala-cli complete bash-v1 "$(( $COMP_CWORD + 1 ))" "${COMP_WORDS[@]}")"
    }

    complete -F _scala-cli_completions scala-cli
fi
