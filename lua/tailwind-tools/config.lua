local M = {}

---@type TailwindTools.Option
M.options = {}

---@class TailwindTools.Option
local defaults = {
  conceal = {
    symbol = "󱏿",
    highlight = {
      fg = "#38BDF8",
    },
    filetypes = {
      "html",
      "astro",
      "php",
      "javascriptreact",
      "typescriptreact",
    }
  },
}

M.setup = function(options) M.options = vim.tbl_deep_extend("keep", options or {}, defaults) end

return M
