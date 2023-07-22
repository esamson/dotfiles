-- Mapping selecting mappings
nmap("<leader><tab>", "<plug>(fzf-maps-n)")
xmap("<leader><tab>", "<plug>(fzf-maps-x)")
omap("<leader><tab>", "<plug>(fzf-maps-o)")

-- Insert mode completion
imap("<c-x><c-k>", "<plug>(fzf-complete-word)")
imap("<c-x><c-f>", "<plug>(fzf-complete-path)")
imap("<c-x><c-j>", "<plug>(fzf-complete-file-ag)")
imap("<c-x><c-l>", "<plug>(fzf-complete-line)")

-- Borrowed from
-- https://github.com/junegunn/fzf.vim/issues/563#issuecomment-486342795
nnoremap("<leader><leader>", ":GFiles<CR>")
nnoremap("<leader>fi", ":Files<CR>")
nnoremap("<leader>H", ":Files ~<CR>")
nnoremap("<leader>C", ":Colors<CR>")
nnoremap("<leader><CR>", ":Buffers<CR>")
nnoremap("<leader>fl", ":Lines<CR>")
nnoremap("<leader>m", ":History<CR>")

