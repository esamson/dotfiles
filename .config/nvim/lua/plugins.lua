local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  -- Packer itself
  use 'wbthomason/packer.nvim'

  -- Solarized color scheme
  use 'overcache/NeoSolarized'

  -- File system sidebar
  use 'nvim-tree/nvim-tree.lua'

  -- Fuzzy search for files
  use {
    'junegunn/fzf.vim',
    requires = {
        'junegunn/fzf',
        run = function()
          vim.fn["fzf#install()"]()
        end
    }
  }

  -- Opens a live preview of the markdown file on a browser
  -- use , { 'do': { -> mkdp#util#install() } }
  use {
    'iamcco/markdown-preview.nvim',
    run = function() vim.fn["mkdp#util#install"]() end,
  }

  -- Markdown syntax
  -- tabular must come before vim-markdown
  use 'godlygeek/tabular'
  use 'preservim/vim-markdown'

  -- PlantUML syntax
  use 'aklt/plantuml-syntax'

  -- Scala Metals
  use {
    'scalameta/nvim-metals',
    requires = {
      'nvim-lua/plenary.nvim'
    }
  }

  -- status line
  use 'itchyny/lightline.vim'

  -- Automatically create directories
  use 'arp242/auto_mkdir2.vim'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
