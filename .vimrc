set nocompatible

" Pathogen init
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

syntax on
filetype plugin indent on

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

" Format JSON
autocmd Filetype json command Format :%!prettyPrintJson

autocmd VimEnter * if exists(":Format") | exe "map <leader>f :Format\<CR>" | endif

" Preview Markdown
autocmd Filetype markdown nmap <leader>p :w \| :silent !remder '%'<CR>
