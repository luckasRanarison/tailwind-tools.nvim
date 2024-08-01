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

  local class_ranges
  local pattern = patterns.builtin_patterns[ft] or custom_patterns[ft]

  if pattern then
    class_ranges = patterns.find_class_ranges(bufnr, pattern[1], pattern[2])
  else
    class_ranges = tresitter.find_class_ranges(bufnr, ft)
  end

  return class_ranges
end

return M
