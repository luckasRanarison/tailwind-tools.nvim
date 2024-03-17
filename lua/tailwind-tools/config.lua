local M = {}

---@type TailwindTools.Option
M.options = {}

---@class TailwindTools.Option
local defaults = {
  conceal = {
    symbol = "󱏿",
    highlight = {
      fg = "#38bdf8",
    },
  },
}

M.setup = function(options) M.options = vim.tbl_deep_extend("keep", options or {}, defaults) end

return M
