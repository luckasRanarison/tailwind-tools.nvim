-- minimal init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
vim.o.swapfile = false

require("lazy").setup({
  { "nvim-lua/plenary.nvim", cmd = "PlenaryBustedDirectory" },
  {
    dir = "./",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function() require("tailwind-tools").setup({}) end,
  },
})

require("lspconfig").tailwindcss.setup({})
