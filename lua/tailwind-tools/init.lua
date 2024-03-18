local M = {}

local config = require("tailwind-tools.config")
local conceal = require("tailwind-tools.conceal")

---@param options TailwindTools.Option
M.setup = function(options)
  config.options = vim.tbl_deep_extend("keep", options, config.options)

  vim.g.tailwind_tools = {
    conceal_ns = vim.api.nvim_create_namespace("tailwind_conceal"),
    conceal_au = vim.api.nvim_create_augroup("tailwind_conceal", {}),
  }

  vim.api.nvim_set_hl(0, "TailwindConceal", config.options.conceal.highlight)
  vim.api.nvim_create_user_command("TailwindConcealEnable", conceal.enable, { nargs = 0 })
  vim.api.nvim_create_user_command("TailwindConcealDisable", conceal.disable, { nargs = 0 })
  vim.api.nvim_create_user_command("TailwindConcealToggle", conceal.toggle, { nargs = 0 })
end

return M
