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
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" Fuzzy search for files
Plug 'ctrlpvim/ctrlp.vim'

" Opens a live preview of the markdown file on a browser
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }

" Sync content from buffer to another tmux pane
" For example, try `mux start scala-repl`
Plug 'jpalardy/vim-slime'

" LSP client
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Coc scala plugin
Plug 'scalameta/coc-metals', {'do': 'yarn install --frozen-lockfile'}

" Markdown syntax
" tabular must come before vim-markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" PlantUML syntax
Plug 'aklt/plantuml-syntax'

" Scala syntax
Plug 'derekwyatt/vim-scala'
call plug#end()

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

set wildmode=longest:list,full

" Live Preview Markdown
autocmd Filetype markdown nmap <leader>r :w \| :silent !remder-app '%' &<CR>
