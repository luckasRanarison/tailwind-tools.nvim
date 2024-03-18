local M = {}

---@class TailwindTools.Option
M.options = {
  document_color = {
    ---@type "foreground" | "background" | "virtual_text"
    kind = "virtual_text",
    virtual_text = "󰝤 ",
  },
  conceal = {
    symbol = "󱏿",
    highlight = {
      fg = "#38BDF8",
    },
  },
}

return M
