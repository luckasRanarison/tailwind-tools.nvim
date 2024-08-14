---@diagnostic disable: unused-local

local M = {}

---@alias TailwindTools.ColorHint "foreground" | "background" | "inline"
---@alias TailwindTools.CmpHighlightHint "foreground" | "background"

---@class TailwindTools.Option
M.options = {
  document_color = {
    enabled = true,
    ---@type TailwindTools.ColorHint
    kind = "inline",
    inline_symbol = "󰝤 ",
    debounce = 200,
  },
  conceal = {
    enabled = false,
    min_length = nil,
    symbol = "󱏿",
    highlight = {
      fg = "#38BDF8",
    },
  },
  cmp = {
    ---@type TailwindTools.CmpHighlightHint
    highlight = "foreground",
  },
  telescope = {
    utilities = {
      callback = function(_name, _css) end,
    },
  },
  extension = {
    queries = {},
    patterns = {},
  },
}

return M
