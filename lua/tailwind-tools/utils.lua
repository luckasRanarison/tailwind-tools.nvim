local M = {}

---@param red number
---@param green number
---@param blue number
---@param style TailwindTools.ColorHint
M.set_hl_from = function(red, green, blue, style)
  local suffix = style == "background" and "Bg" or "Fg"
  local color = string.format("%02x%02x%02x", red, green, blue)
  local group = "TailwindColor" .. suffix .. color
  local opts

  if style == "background" then
    -- https://stackoverflow.com/questions/3942878
    local luminance = red * 0.299 + green * 0.587 + blue * 0.114
    local fg = luminance > 186 and "#000000" or "#FFFFFF"
    opts = { fg = fg, bg = "#" .. color }
  else
    opts = { fg = "#" .. color }
  end

  if vim.fn.hlID(group) < 1 then vim.api.nvim_set_hl(0, group, opts) end

  return group
end

return M
