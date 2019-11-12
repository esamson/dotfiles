" Exclude files and directories using Vim's wildignore and
" CtrlP's own g:ctrlp_custom_ignore.
" If a custom listing command is being used, exclusions are ignored
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

if executable('rg')
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'

    " rg is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0
else
    " Ignore files in .gitignore
    let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
endif
