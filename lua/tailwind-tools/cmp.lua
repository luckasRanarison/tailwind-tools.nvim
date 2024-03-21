local M = {}

local utils = require("tailwind-tools.utils")

-- Formatting utility for https://github.com/onsails/lspkind.nvim
---@param entry cmp.Entry
---@param vim_item any
---@return any
M.lspkind_format = function(entry, vim_item)
  local doc = entry.completion_item.documentation

  if vim_item.kind == "Color" and doc then
    local content = type(doc) == "string" and doc or doc.value
    local base, _, _, _r, _g, _b = 10, content:find("rgba?%((%d+), (%d+), (%d+)")

    if not _r then
      base, _, _, _r, _g, _b = 16, content:find("#(%x%x)(%x%x)(%x%x)")
    end

    if _r then
      local r, g, b = tonumber(_r, base), tonumber(_g, base), tonumber(_b, base)
      vim_item.kind_hl_group = utils.set_hl_from(r, g, b, "foreground")
    end
  end

  return vim_item
end

return M
