set nocompatible

" Install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Sensible defaults
Plug 'tpope/vim-sensible'

" Solarized color scheme
Plug 'altercation/vim-colors-solarized'

" File system sidebar
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }

" Fuzzy search for files
Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'junegunn/fzf.vim'

" Opens a live preview of the markdown file on a browser
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }

" Markdown syntax
" tabular must come before vim-markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" PlantUML syntax
Plug 'aklt/plantuml-syntax'

" Scala syntax
Plug 'derekwyatt/vim-scala'

" status line
Plug 'itchyny/lightline.vim'

" Automatically create directories
Plug 'arp242/auto_mkdir2.vim'

call plug#end()

set tabstop=4
set shiftwidth=4
set expandtab

set wrap
set linebreak
set nolist
let &showbreak="\u21aa   "

set number
set cpoptions+=n
nmap <C-N><C-N> :set invnumber<CR>
set colorcolumn=80

set directory=$HOME/Downloads//
set backupdir=$HOME/Downloads//
set backupskip=/tmp/*,/private/tmp/*

set wildmode=longest:list,full

set noshowmode

" Live Preview Markdown
autocmd Filetype markdown nmap <leader>r :w \| :silent !remder-app '%' &<CR>

" Spell check on Markdown
autocmd Filetype markdown setlocal spell spelllang=en_us
