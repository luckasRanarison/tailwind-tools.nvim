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

  health.start("Parsers")

  check_parser("html")
  check_parser("tsx")
  check_parser("css")

  health.start("tailwindcss-language-server")

  if vim.fn.executable("tailwindcss-language-server") then
    health.ok("installed")
  else
    health.error("not installed")
  end

  health.start("nvim-lspconfig (optional)")

  if pcall(require, "lspconfig") then
    health.ok("installed")
  else
    health.warn("not installed")
  end

  health.start("telescope.nvim (optional)")

  if pcall(require, "telescope") then
    health.ok("installed")
  else
    health.warn("not installed")
  end
end

return M
