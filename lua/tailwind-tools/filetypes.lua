local M = {}

local config = require("tailwind-tools.config")

local filetypes = {
  treesitter = {
    "html",
    "css",
    "php",
    "blade",
    "twig",
    "vue",
    "heex",
    "astro",
    "templ",
    "svelte",
    "elixir",
    "htmldjango",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
  },
  luapattern = {
    rust = { "class=[\"']([^\"']+)[\"']" },
  },
  server = {
    eelixir = "html-eex",
    eruby = "erb",
    templ = "html",
    rust = "html",
    heex = "html",
  },
}

---@param ft string
M.get_patterns = function(ft)
  return filetypes.luapattern[ft] or config.options.extension.patterns[ft] or {}
end

---@param ft string
M.has_queries = function(ft)
  return vim.tbl_contains(filetypes.treesitter, ft)
    or vim.tbl_contains(config.options.extension.queries, ft)
end

M.get_server_map = function() return filetypes.server end

---@return string[]
M.get_all = function()
  local result = {}
  local extension = config.options.extension

  vim.list_extend(result, filetypes.treesitter)
  vim.list_extend(result, extension.queries)
  vim.list_extend(result, vim.tbl_keys(filetypes.luapattern))
  vim.list_extend(result, vim.tbl_keys(extension.patterns))

  return result
end

return M
