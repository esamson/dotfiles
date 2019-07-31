set nocompatible

" Pathogen init
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

syntax on
filetype plugin indent on

set autoread

set hlsearch

set tabstop=4
set shiftwidth=4
set expandtab

set wrap
set linebreak
set nolist
set showbreak=↵\ \ \ 

set number
set cpoptions+=n
nmap <C-N><C-N> :set invnumber<CR>
set colorcolumn=80

set directory=$HOME/Downloads//
set backupdir=$HOME/Downloads//
set backupskip=/tmp/*,/private/tmp/*

set wildmenu
set wildmode=longest:list,full

" Disable markdown folding
let g:vim_markdown_folding_disabled=1

" Toggle NERDTree
map <leader>n :NERDTreeToggle<CR>

" Ignores
" set wildignore+=*/tmp/*,*.so,*.swp,*.zip
" let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git)$',
  \ 'file': '\v\.(class)$',
  \ }

" Ignore files in .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" vim-autoformat
noremap <leader>f :Autoformat<CR>
let g:formatdef_pretty_print_json = "'prettyPrintJson'"
let g:formatters_json = ['pretty_print_json']
let g:formatdef_scalafmt = "'scalafmt'"
let g:formatters_scala = ['scalafmt']

" Preview Markdown
autocmd Filetype markdown nmap <leader>p :w \| :silent !remder '%'<CR>

" Live Preview Markdown
autocmd Filetype markdown nmap <leader>r :w \| :silent !remder-app '%' &<CR>

" vim-slime configuration
let g:slime_target = "tmux"
