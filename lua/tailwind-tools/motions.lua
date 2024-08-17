local M = {}

local log = require("tailwind-tools.log")
local classes = require("tailwind-tools.classes")

---@param comp fun(a: number, b: number): boolean
local move_to_class = function(comp)
  local bufnr = vim.api.nvim_get_current_buf()
  local class_ranges = classes.get_ranges(bufnr)

  if #class_ranges == 0 then return log.info("No classes") end

  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

  table.sort(class_ranges, function(a, b)
    local a_row, a_col = unpack(a)
    local b_row, b_col = unpack(b)
    return a_row == b_row and comp(b_col, a_col) or comp(b_row, a_row)
  end)

  for _, range in ipairs(class_ranges) do
    local node_row, node_col = unpack(range)
    local row = cursor_row - 1

    if comp(node_row, row) or (node_row == row and comp(node_col, cursor_col)) then
      return vim.api.nvim_win_set_cursor(0, { node_row + 1, node_col })
    end
  end
end

M.move_to_next_class = function()
  for _ = 1, vim.v.count1 do
    move_to_class(function(a, b) return a > b end)
  end
end

M.move_to_prev_class = function()
  for _ = 1, vim.v.count1 do
    move_to_class(function(a, b) return a < b end)
  end
end

return M
