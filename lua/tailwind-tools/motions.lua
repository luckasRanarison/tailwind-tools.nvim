local M = {}

local log = require("tailwind-tools.log")
local treesitter = require("tailwind-tools.treesitter")

---@param comp fun(a: number, b: number): boolean
local move_to_class = function(comp)
  local nodes = treesitter.find_class_nodes(0, true)

  if not nodes then return end
  if #nodes == 0 then return log.info("No classes") end

  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

  table.sort(nodes, function(a, b)
    local a_row, a_col = treesitter.get_class_range(a, 0)
    local b_row, b_col = treesitter.get_class_range(b, 0)
    return a_row == b_row and comp(b_col, a_col) or comp(b_row, a_row)
  end)

  for _, node in ipairs(nodes) do
    local node_row, node_col = treesitter.get_class_range(node, 0)
    local row = cursor_row - 1

    if comp(node_row, row) or (node_row == row and comp(node_col, cursor_col)) then
      return vim.api.nvim_win_set_cursor(0, { node_row + 1, node_col })
    end
  end
end

M.move_to_next_class = function()
  move_to_class(function(a, b) return a > b end)
end

M.move_to_prev_class = function()
  move_to_class(function(a, b) return a < b end)
end

return M
