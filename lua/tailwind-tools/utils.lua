local M = {}

local name_map = {
  inline = "Fg",
  foreground = "Fg",
  background = "Bg",
}

---@param red number | string
---@param green number | string
---@param blue number | string
---@param kind TailwindTools.ColorHint
M.set_hl_from = function(red, green, blue, kind)
  local color = string.format("%02x%02x%02x", red, green, blue)
  local group = "TailwindColor" .. name_map[kind] .. color
  local opts = nil

  if kind == "background" then
    local r, g, b = tonumber(red), tonumber(green), tonumber(blue)
    -- https://stackoverflow.com/questions/3942878
    local luminance = r * 0.299 + g * 0.587 + b * 0.114
    local fg = luminance > 186 and "#000000" or "#FFFFFF"
    opts = { fg = fg, bg = "#" .. color }
  else
    opts = { fg = "#" .. color }
  end

  if vim.fn.hlID(group) < 1 then vim.api.nvim_set_hl(0, group, opts) end

  return group
end

return M
