set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" This set up uses vundle. When setting up a new box, you first have to:
" $ git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" $ vim +PluginInstall +qall
Plugin 'VundleVim/Vundle.vim'

" Plugins
" Run ':PluginInstall' if you add anything new
Plugin 'altercation/vim-colors-solarized'
" Plugin 'tpope/vim-markdown'
Plugin 'plasticboy/vim-markdown'
" Plugin 'esamson/vim-markdown-preview'
" Plugin 'rust-lang/rust.vim'
Plugin 'fatih/vim-go'

call vundle#end()

filetype plugin indent on
syntax on

" nmap <leader>p :Mm<CR>
" let g:VMPoutputdirectory=$HOME."/Downloads"
" let g:VMPstylesheet="simple-github.css"

" On OS X, Preview using
" https://chrome.google.com/webstore/detail/markdown-reader/gpoigdifkoadgajcincpilkjmejcaanc
nmap <leader>p :!open -a /Applications/Google\ Chrome.app %<CR>

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

