local M = {}

local treesitter = require("tailwind-tools.treesitter")

M.move_to_next_class = function()
  local nodes = treesitter.get_class_nodes(0, true)

  if not nodes then return end

  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

  table.sort(nodes, function(a, b)
    local a_row, a_col = treesitter.get_class_range(a, 0)
    local b_row, b_col = treesitter.get_class_range(b, 0)
    return a_row == b_row and a_col < b_col or a_row < b_row
  end)

  for _, node in ipairs(nodes) do
    local node_row, node_col = treesitter.get_class_range(node, 0)

    if node_row > cursor_row - 1 or (node_row == cursor_row - 1 and node_col > cursor_col) then
      return vim.api.nvim_win_set_cursor(0, { node_row + 1, node_col })
    end
  end
end

M.move_to_prev_class = function()
  local nodes = treesitter.get_class_nodes(0, true)

  if not nodes then return end

  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

  table.sort(nodes, function(a, b)
    local a_row, a_col = treesitter.get_class_range(a, 0)
    local b_row, b_col = treesitter.get_class_range(b, 0)
    return a_row == b_row and a_col > b_col or a_row > b_row
  end)

  for _, node in ipairs(nodes) do
    local node_row, node_col = treesitter.get_class_range(node, 0)

    if node_row < cursor_row - 1 or (node_row == cursor_row - 1 and node_col < cursor_col) then
      return vim.api.nvim_win_set_cursor(0, { node_row + 1, node_col })
    end
  end
end

return M
