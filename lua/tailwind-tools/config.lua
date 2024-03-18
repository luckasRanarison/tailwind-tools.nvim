local M = {}

---@class TailwindTools.Option
M.options = {
  document_color = {
    ---@type "foreground" | "background" | "inline"
    kind = "inline",
    inline_symbol = "󰝤 ",
  },
  conceal = {
    symbol = "󱏿",
    highlight = {
      fg = "#38BDF8",
    },
  },
}

return M
