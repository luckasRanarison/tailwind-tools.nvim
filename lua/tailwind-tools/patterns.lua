local M = {}

---@param b_start number
---@param b_end number
---@param bufnr number
local function byte_range_to_pos(b_start, b_end, bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local line_offsets = {}

  for i = 1, line_count do
    line_offsets[i] = vim.api.nvim_buf_get_offset(bufnr, i - 1)
  end

  local s_row, s_col, e_row, e_col

  for line, offset in pairs(line_offsets) do
    local next_offset = line_offsets[line + 1]

    if not next_offset or b_start >= offset and b_start < next_offset then
      s_row = line - 1
      s_col = b_start - offset
    end

    if not next_offset or b_end >= offset and b_end < next_offset then
      e_row = line - 1
      e_col = b_end - offset
      break
    end
  end

  return s_row, s_col, e_row, e_col
end

---@param bufnr number
---@param pattern_definition string | { pattern: string, delimiter: string }
M.find_class_ranges = function(bufnr, pattern_definition)
  local results = {}

  local pattern
  local delimiter = nil
  if type(pattern_definition) == "table" then
    pattern = pattern_definition.pattern
    if pattern_definition.delimiter then
      delimiter = {
        raw = pattern_definition.delimiter,
        pattern = string.gsub(pattern_definition.delimiter, "%W", "%%%1"),
      }
    end
  else
    pattern = pattern_definition
  end

  if not pattern then return results end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  local substr = table.concat(lines, "\n")
  local offset = 0

  while true do
    local b_start, b_end, class = substr:find(pattern)

    if b_start == nil then break end

    substr = substr:sub(b_start)
    offset = offset + b_start - 1

    local match_len = b_end - b_start
    local class_start = substr:find(class, 1, true) + offset - 1
    local class_end = class_start + #class
    local s_row, s_col, e_row, e_col = byte_range_to_pos(class_start, class_end, bufnr)

    results[#results + 1] = { s_row, s_col, e_row, e_col, delimiter = delimiter }
    substr = substr:sub(match_len)
    offset = offset + match_len - 1
  end

  return results
end

return M
