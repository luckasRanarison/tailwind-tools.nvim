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
    "eruby",
    "templ",
    "svelte",
    "elixir",
    "eelixir",
    "htmldjango",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
  },
  luapattern = {
    rust = { "class[=:]%s*[\"']([^\"']+)[\"']" },
    clojure = {
      -- :class "cls-1 cls-2"
      ':class%s+"([^"]+)"',
      -- ^:tw \"cls-1 cls-2\"
      '%^:tw%s+"([^"]+)"',
      -- [:div#id.cls-1.cls-2] [:#id.cls-1.cls-2] [:.cls-1.cls-2]
      { pattern = "%[:[%w%-]*(?:#[%w%-]+)?((?:%.[%w%-]+)+)", delimiter = "%." },
    },
  },
  server = {
    elixir = "phoenix-heex",
    eelixir = "html-eex",
    eruby = "erb",
    templ = "html",
    rust = "html",
    heex = "phoenix-heex",
    clojure = "html",
  },
}

---@param ft string
M.get_patterns = function(ft)
  return config.options.extension.patterns[ft] or filetypes.luapattern[ft] or {}
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
