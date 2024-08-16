local M = {}

local log = require("tailwind-tools.log")
local lsp = require("tailwind-tools.lsp")
local state = require("tailwind-tools.state")
local config = require("tailwind-tools.config")
local conceal = require("tailwind-tools.conceal")
local motions = require("tailwind-tools.motions")

local function register_usercmd()
  local usercmd = vim.api.nvim_create_user_command

  usercmd("TailwindConcealEnable", conceal.enable, { nargs = 0 })
  usercmd("TailwindConcealDisable", conceal.disable, { nargs = 0 })
  usercmd("TailwindConcealToggle", conceal.toggle, { nargs = 0 })
  usercmd("TailwindSort", lsp.sort_classes, { nargs = 0 })
  usercmd("TailwindSortSelection", lsp.sort_selection, { range = "%" })
  usercmd("TailwindColorEnable", lsp.enable_color, { nargs = 0 })
  usercmd("TailwindColorDisable", lsp.disable_color, { nargs = 0 })
  usercmd("TailwindColorToggle", lsp.toggle_colors, { nargs = 0 })
  usercmd("TailwindNextClass", motions.move_to_next_class, { nargs = 0 })
  usercmd("TailwindPrevClass", motions.move_to_prev_class, { nargs = 0 })
  usercmd("TailwindSortSync", function() lsp.sort_classes(true) end, { nargs = 0 })
  usercmd("TailwindSortSelectionSync", function() lsp.sort_selection(true) end, { range = "%" })
end

local function register_autocmd()
  local autocmd = vim.api.nvim_create_autocmd

  autocmd("LspAttach", {
    group = vim.g.tailwind_tools.color_au,
    callback = lsp.on_attach,
  })

  autocmd("BufEnter", {
    group = vim.g.tailwind_tools.conceal_au,
    callback = function()
      if state.conceal.enabled then conceal.enable() end
    end,
  })
end

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

  local server_opts = config.options.server
  local has_telescope, telescope = pcall(require, "telescope")
  local has_lspconfig, lspconfig = pcall(require, "lspconfig")

  if has_telescope then telescope.load_extension("tailwind") end
  if has_lspconfig and server_opts.override then lsp.setup(server_opts.settings, lspconfig) end

  register_usercmd()
  register_autocmd()
end

return M
