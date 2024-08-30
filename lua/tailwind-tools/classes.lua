local M = {}

local patterns = require("tailwind-tools.patterns")
local filetypes = require("tailwind-tools.filetypes")
local tresitter = require("tailwind-tools.treesitter")

---@class TailwindTools.ClassFilter
---@field sortable? boolean

---@param bufnr number
---@param filters? TailwindTools.ClassFilter
---@return number[][]
M.get_ranges = function(bufnr, filters)
  local results = {}
  local ft = vim.bo[bufnr].ft
  local pattern_list = filetypes.get_patterns(ft)

  filters = filters or {}

  for _, pattern in pairs(pattern_list) do
    local ranges = patterns.find_class_ranges(bufnr, pattern)
    vim.list_extend(results, ranges)
  end

  if filetypes.has_queries(ft) then
    local ranges = tresitter.find_class_ranges(bufnr, ft, filters)
    vim.list_extend(results, ranges)
  end

  return results
end

return M
