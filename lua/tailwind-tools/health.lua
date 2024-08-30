local M = {}

M.check = function()
  local health = vim.health

  local check_parser = function(name)
    if pcall(vim.treesitter.get_parser, 0, name) then
      health.ok(name .. " parser is installed")
    else
      health.error(name .. " parser is not installed")
    end
  end

  health.start("Treesitter parsers")

  check_parser("html")
  check_parser("tsx")
  check_parser("css")

  health.start("tailwindcss-language-server")

  if vim.fn.executable("tailwindcss-language-server") then
    health.ok("installed")
  else
    health.error("not installed")
  end

  health.start("Plugin dependencies (optional)")

  if pcall(require, "lspconfig") then
    health.ok("nvim-lspconfig is installed")
  else
    health.error("nvim-lspconfig is not installed")
  end

  if pcall(require, "telescope") then
    health.ok("telescope.nvim is installed")
  else
    health.error("telescope.nvim is not installed")
  end

  require("provider.node.health").check()
end

return M
