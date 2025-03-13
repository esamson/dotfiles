require('plugins')
require('mappings')
require('neovide')
require('plugin-settings.fzf')
require('plugin-settings.markdown-preview')
require('plugin-settings.nvim-metals')
require('plugin-settings.nvim-tree')
require('plugin-settings.vim-markdown')

-- tabs are four spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- wrap long lines, indent with right arrow symbol
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:4,sbr"
vim.opt.showbreak = "\u{21b3}"

vim.opt.number = true

vim.opt.colorcolumn = "80"

vim.opt.wildmode = "longest:list,full"

-- https://github.com/overcache/NeoSolarized
vim.opt.termguicolors = true
vim.cmd [[colorscheme NeoSolarized]]

-- Live Preview Markdown
vim.api.nvim_create_autocmd(
  "Filetype",
  {
    pattern = "markdown",
    callback = markdownRemder
  }
)

-- Spell check on Markdown
vim.api.nvim_create_autocmd(
  "Filetype",
  {
    pattern = "markdown",
    command = "setlocal spell spelllang=en_us"
  }
)

