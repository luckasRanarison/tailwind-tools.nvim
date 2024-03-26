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

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      sync_install = true,
      ensure_installed = { "html", "tsx", "css", "astro" },
      highlight = { enable = true },
    },
    setup = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
  },
  { dir = "../", dependecies = { "nvim-treesitter/nvim-treesitter" } },
})
