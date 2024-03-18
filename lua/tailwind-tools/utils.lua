local M = {}

---@param r number | string
---@param g number | string
---@param b number | string
M.set_hl_from = function(r, g, b)
  local color_value = string.format("%02x%02x%02x", r, g, b)
  local group = "TailwindColor" .. color_value
  if vim.fn.hlID(group) < 1 then vim.api.nvim_set_hl(0, group, { fg = "#" .. color_value }) end
  return group
end

return M
