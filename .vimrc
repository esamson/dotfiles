set nocompatible

" Install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'altercation/vim-colors-solarized'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'derekwyatt/vim-scala'
Plug 'jpalardy/vim-slime'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
call plug#end()

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

" Preview Markdown
autocmd Filetype markdown nmap <leader>p :w \| :silent !remder '%'<CR>

" Live Preview Markdown
autocmd Filetype markdown nmap <leader>r :w \| :silent !remder-app '%' &<CR>

" vim-slime configuration
let g:slime_target = "tmux"
