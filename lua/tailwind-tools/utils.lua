local M = {}

---@param red number
---@param green number
---@param blue number
---@param style TailwindTools.ColorHint
M.set_hl_from = function(red, green, blue, style)
  local suffix = style == "background" and "Bg" or "Fg"
  local color = string.format("%02x%02x%02x", red, green, blue)
  local hl_name = "TailwindColor" .. suffix .. color
  local opts

  if style == "background" then
    -- https://stackoverflow.com/questions/3942878
    local luminance = red * 0.299 + green * 0.587 + blue * 0.114
    local fg = luminance > 186 and "#000000" or "#FFFFFF"
    opts = { fg = fg, bg = "#" .. color }
  else
    opts = { fg = "#" .. color }
  end

  if not vim.api.nvim_get_hl(0, { name = hl_name })[1] then
    vim.api.nvim_set_hl(0, hl_name, opts)
  end

  return hl_name
end

---@param s string
M.extract_color = function(s)
  local base, _, _, r, g, b = 10, s:find("rgba?%((%d+).%s*(%d+).%s*(%d+)")

  if not r then
    base, _, _, r, g, b = 16, s:find("#(%x%x)(%x%x)(%x%x)")
  end

  if r then return tonumber(r, base), tonumber(g, base), tonumber(b, base) end
end

---Returns the 0-based range of the visual selection (start_row, start_col, end_row, end_col)
M.get_visual_range = function()
  local s_row = vim.fn.line("'<") - 1
  local s_col = vim.fn.col("'<") - 1
  local e_row = vim.fn.line("'>") - 1
  local e_col = vim.fn.col("'>")

  return s_row, s_col, e_row, e_col
end

return M
