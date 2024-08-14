local M = {}

local log = require("tailwind-tools.log")
local lsp = require("tailwind-tools.lsp")
local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local conceal = require("tailwind-tools.conceal")
local motions = require("tailwind-tools.motions")

---@param options TailwindTools.Option
M.setup = function(options)
  config.options = vim.tbl_deep_extend("keep", options or {}, config.options)

  state.conceal.enabled = config.options.conceal.enabled
  state.color.enabled = config.options.document_color.enabled

  if vim.version().minor < 10 and config.options.document_color.kind == "inline" then
    log.warn(
      "Neovim v0.10 is required for inline color hints, using fallback option."
        .. ' Should use value "foreground" or "background" for document_color.kind'
    )
    config.options.document_color.kind = "background"
  end

  vim.g.tailwind_tools = {
    color_ns = vim.api.nvim_create_namespace("tailwind_colors"),
    color_au = vim.api.nvim_create_augroup("tailwind_colors", {}),
    conceal_ns = vim.api.nvim_create_namespace("tailwind_conceal"),
    conceal_au = vim.api.nvim_create_augroup("tailwind_conceal", {}),
  }

  vim.api.nvim_set_hl(0, "TailwindConceal", config.options.conceal.highlight)

  local cmd = vim.api.nvim_create_user_command

  cmd("TailwindConcealEnable", conceal.enable, { nargs = 0 })
  cmd("TailwindConcealDisable", conceal.disable, { nargs = 0 })
  cmd("TailwindConcealToggle", conceal.toggle, { nargs = 0 })
  cmd("TailwindSort", lsp.sort_classes, { nargs = 0 })
  cmd("TailwindSortSelection", lsp.sort_selection, { range = "%" })
  cmd("TailwindColorEnable", lsp.enable_color, { nargs = 0 })
  cmd("TailwindColorDisable", lsp.disable_color, { nargs = 0 })
  cmd("TailwindColorToggle", lsp.toggle_colors, { nargs = 0 })
  cmd("TailwindNextClass", motions.move_to_next_class, { nargs = 0 })
  cmd("TailwindPrevClass", motions.move_to_prev_class, { nargs = 0 })
  cmd("TailwindSortSync", function() lsp.sort_classes(true) end, { nargs = 0 })
  cmd("TailwindSortSelectionSync", function() lsp.sort_selection(true) end, { range = "%" })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.g.tailwind_tools.color_au,
    callback = lsp.on_attach,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.g.tailwind_tools.conceal_au,
    callback = function()
      if state.conceal.enabled then conceal.enable() end
    end,
  })

  local has_telescope, telescope = pcall(require, "telescope")
  if has_telescope then telescope.load_extension("tailwind") end
end

return M
