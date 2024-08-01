local M = {}

local config = require("tailwind-tools.config")
local patterns = require("tailwind-tools.patterns")
local filetypes = require("tailwind-tools.filetypes")
local tresitter = require("tailwind-tools.treesitter")

---@param bufnr number
M.get_ranges = function(bufnr)
  local ft = vim.bo[bufnr].ft
  local custom_patterns = config.options.custom_patterns
  local pattern_ft = vim.tbl_keys(custom_patterns)
  local query_ft = vim.tbl_keys(config.options.custom_queries)

  vim.list_extend(filetypes, query_ft)
  vim.list_extend(filetypes, pattern_ft)

  if not vim.tbl_contains(filetypes, ft) then return end

  local results = {}
  local pattern_list = patterns.builtin_patterns[ft] or custom_patterns[ft]

  for _, pattern in pairs(pattern_list or {}) do
    vim.list_extend(results, patterns.find_class_ranges(bufnr, pattern))
  end

  vim.list_extend(results, tresitter.find_class_ranges(bufnr, ft) or {})

  return results
end

return M
