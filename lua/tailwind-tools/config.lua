local M = {}

---@alias TailwindTools.ColorHint "foreground" | "background" | "inline"

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
  custom_filetypes = {},
  supported_filetypes = {
    "html",
    "css",
    "php",
    "twig",
    "vue",
    "svelte",
    "astro",
    "htmldjango",
    "javascriptreact",
    "typescriptreact",
  },
}

return M
