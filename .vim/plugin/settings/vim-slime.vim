" vim-slime configuration
let g:slime_target = "tmux"

" By default, expect vim on the left pane and REPL on the right pane
let g:slime_default_config = {"socket_name": "default", "target_pane": "{right-of}"}
