---@diagnostic disable: unused-local

local M = {}

local units = require("tailwind-tools.units")

---@alias TailwindTools.ColorHint "foreground" | "background" | "inline"
---@alias TailwindTools.CmpHighlightHint "foreground" | "background"

---@class TailwindTools.Option
M.options = {
  ---@class TailwindTools.ServerOption
  server = {
    override = true,
    settings = {},
    on_attach = function(_client, _bufnr) end,
  },
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
  keymaps = {
    smart_increment = {
      enable = true,
      units = units,
    },
  },
}

return M
