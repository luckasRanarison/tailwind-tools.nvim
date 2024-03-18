local M = {}

local utils = require("tailwind-tools.utils")

-- Formatting utility for https://github.com/onsails/lspkind.nvim
---@param entry cmp.Entry
---@param vim_item any
---@return any
M.lspkind_format = function(entry, vim_item)
  local doc = entry.completion_item.documentation

  if vim_item.kind == "Color" and type(doc) == "string" then
    local _, _, r, g, b = doc:find("rgba?%((%d+), (%d+), (%d+)")
    if r then vim_item.kind_hl_group = utils.set_hl_from(r, g, b, "foreground") end
  end

  return vim_item
end

return M
