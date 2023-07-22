function set_keymap(mode, shortcut, command)
  vim.keymap.set(
    mode, shortcut, command,
    { noremap = true, silent = true}
  )
end

function map(shortcut, command)
  set_keymap('', shortcut, command)
end

function nmap(shortcut, command)
  set_keymap('n', shortcut, command)
end

function omap(shortcut, command)
  set_keymap('o', shortcut, command)
end

function imap(shortcut, command)
  set_keymap('i', shortcut, command)
end

function xmap(shortcut, command)
  set_keymap('x', shortcut, command)
end

function nnoremap(shortcut, command)
  nmap(shortcut, command)
end

-- toggle line numbers with ctrl-n, ctrl-n
nmap("<C-N><C-N>", ":set invnumber<CR>")

function markdownRemder()
  nmap("<leader>r", ":w | :silent !remder-app '%' &<CR>")
end
