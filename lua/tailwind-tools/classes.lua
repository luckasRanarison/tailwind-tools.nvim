local M = {}

local patterns = require("tailwind-tools.patterns")
local filetypes = require("tailwind-tools.filetypes")
local tresitter = require("tailwind-tools.treesitter")
local opts = require("tailwind-tools.config").options

---@param bufnr number
---@return number[][]
M.get_ranges = function(bufnr)
  local results = {}
  local ft = vim.bo[bufnr].ft
  local query_list = vim.tbl_extend("force", filetypes.treesitter, opts.custom_queries)
  local pattern_list = vim.tbl_extend("force", filetypes.luapattern, opts.custom_patterns)

  for _, pattern in pairs(pattern_list[ft] or {}) do
    vim.list_extend(results, patterns.find_class_ranges(bufnr, pattern))
  end

  if vim.tbl_contains(query_list, ft) then
    vim.list_extend(results, tresitter.find_class_ranges(bufnr, ft) or {})
  end

  return results
end

return M
