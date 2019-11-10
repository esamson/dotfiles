" Toggle NERDTree
map <leader>n :NERDTreeToggle<CR>

" Close vim if the only window left open is NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
