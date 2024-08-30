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

  local function check_plugin(name, module)
    if pcall(require, module) then
      health.ok(name .. " is installed")
    else
      health.error(name .. " is not installed")
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

  check_plugin("nvim-lspconfig", "lspconfig")
  check_plugin("telescope.nvim", "telescope")

  local has_node_health, node_health = pcall(require, "provider.node.health")

  if has_node_health then node_health.check() end
end

return M
