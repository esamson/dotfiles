local api = vim.api

local metals_config = require("metals").bare_config()

-- Autocmd to start metals
local nvim_metals_group = api.nvim_create_augroup("nvim-metals", {clear = true})
api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt" },
  callback = function()
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group
})
