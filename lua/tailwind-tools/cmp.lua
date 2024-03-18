local M = {}

-- Formatting utility for https://github.com/onsails/lspkind.nvim
---@param entry cmp.Entry
---@param vim_item any
---@return any
M.lspkind_format = function(entry, vim_item)
  local doc = entry.completion_item.documentation

  if vim_item.kind == "Color" and type(doc) == "string" then
    local _, _, r, g, b = doc:find("rgba?%((%d+), (%d+), (%d+)")
    if r then
      local color = string.format("%02x%02x%02x", r, g, b)
      local group = "TailwindColor" .. color
      if vim.fn.hlID(group) < 1 then vim.api.nvim_set_hl(0, group, { fg = "#" .. color }) end
      vim_item.kind_hl_group = group
    end
  end

  return vim_item
end

return M
