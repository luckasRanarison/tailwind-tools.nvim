local assert = require("luassert")
local treesitter = require("tailwind-tools.treesitter")

local M = {}

local Runner = {}

Runner.__index = Runner

---@param file_path string
---@param filetype string?
function Runner:new(file_path, filetype)
  assert.same(1, vim.fn.filereadable(file_path), file_path .. " is not readable")
  vim.cmd.edit(file_path)
  if filetype then vim.bo.filetype = filetype end
  return setmetatable({ nodes = {} }, self)
end

function Runner:classes(expected)
  it("Should get classes", function()
    self.nodes = assert(treesitter.get_class_nodes(0, true), "Expected nodes")
    assert.same(expected, #self.nodes, "Mismatched node count")
  end)
end

function Runner:ranges(expected)
  it("Should get ranges", function()
    for i, node in pairs(self.nodes) do
      local start_row, start_col, end_row, end_col = treesitter.get_class_range(node, 0)

      assert.same(expected[i][1], start_row, "Mismatched start row for node " .. i)
      assert.same(expected[i][2], start_col, "Mismatched start column for node " .. i)
      assert.same(expected[i][3], end_row, "Mismatched end row for node " .. i)
      assert.same(expected[i][4], end_col, "Mismatched end column for node " .. i)
    end
  end)
end

M.Runner = Runner

return M
