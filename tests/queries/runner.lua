local M = {}

local assert = require("luassert")
local classes = require("tailwind-tools.classes")

---@class QueryTestSpec
---@field name string
---@field provider "treesitter" | "luapattern"
---@field file string
---@field filetype? string
---@field ranges number[][]
---@field filters? TailwindTools.ClassFilter

---@param spec QueryTestSpec
M.test = function(spec)
  describe(string.format("query %s (%s):", spec.name, spec.provider), function()
    assert.same(1, vim.fn.filereadable(spec.file), spec.file .. " is not readable")

    vim.cmd.edit(spec.file)
    vim.bo.filetype = spec.filetype or vim.bo.filetype

    local ranges = classes.get_ranges(0, spec.filters)

    it(
      "Should get class count",
      function() assert.same(#ranges, #spec.ranges, "Mismatched class count") end
    )

    it(
      "Should get ranges",
      function() assert.same(ranges, spec.ranges, "Mismatched class ranges") end
    )
  end)
end

return M
